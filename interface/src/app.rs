//! Estado e lógica de interação da TUI.
//!
//! [`App`] guarda todo o estado; [`App::handle_key`] roteia as teclas para o
//! handler da tela atual ([`Screen`]); as ações que tocam a rede delegam ao
//! módulo [`crate::api`] e gravam o resultado em `status` para o `ui` exibir.

use crossterm::event::KeyCode;
use ratatui::widgets::TableState;

use crate::api::{self, CreateUnidade, FilterParams, Unidade};

/// Valida (no cliente) que o CNUC contém apenas dígitos `0-9`.
/// Retorna a mensagem de erro em português quando inválido.
fn check_cnuc_digits(cnuc: &str) -> Result<(), String> {
    if cnuc.chars().all(|c| c.is_ascii_digit()) {
        Ok(())
    } else {
        Err("Erro: CNUC deve conter apenas números (0-9).".into())
    }
}

/// Valida (no cliente) que a UF tem exatamente 2 letras.
/// `None`/vazio é aceito, pois o campo é opcional.
fn check_uf(uf: &Option<String>) -> Result<(), String> {
    match uf {
        Some(v) if v.chars().count() != 2 || !v.chars().all(|c| c.is_alphabetic()) => {
            Err("Erro: UF deve conter exatamente 2 letras (ex: SP).".into())
        }
        _ => Ok(()),
    }
}

/// Tela atualmente em foco; decide renderização e roteamento de teclas.
#[derive(PartialEq, Eq, Clone, Copy)]
pub enum Screen {
    List,
    Create,
    Filter,
    Edit,
    DeleteConfirm,
}

/// Campo de texto editável de um formulário.
#[derive(Default, Clone)]
pub struct Input {
    pub value: String,
}

impl Input {
    pub fn push(&mut self, c: char) {
        self.value.push(c);
    }

    pub fn pop(&mut self) {
        self.value.pop();
    }

    pub fn clear(&mut self) {
        self.value.clear();
    }
}

/// Conjunto de campos navegáveis por Tab, com índice do campo em foco.
pub struct Form {
    pub fields: Vec<Input>,
    pub focused: usize,
}

impl Form {
    pub fn new(n: usize) -> Self {
        Self {
            fields: vec![Input::default(); n],
            focused: 0,
        }
    }

    pub fn clear(&mut self) {
        for f in &mut self.fields {
            f.clear();
        }
        self.focused = 0;
    }

    pub fn next(&mut self) {
        self.focused = (self.focused + 1) % self.fields.len();
    }

    pub fn prev(&mut self) {
        self.focused = (self.focused + self.fields.len() - 1) % self.fields.len();
    }

    /// Valor do campo `i`, ou `None` quando vazio (mapeado para omissão no JSON).
    pub fn val(&self, i: usize) -> Option<String> {
        let v = &self.fields[i].value;
        if v.is_empty() {
            None
        } else {
            Some(v.clone())
        }
    }
}

/// Estado global da aplicação. `create` é reaproveitado nas telas Create e Edit.
pub struct App {
    pub screen: Screen,
    /// Unidades atualmente carregadas e exibidas na tabela.
    pub units: Vec<Unidade>,
    pub table_state: TableState,
    /// Formulário de criação/edição (mesmos campos em ambos os modos).
    pub create: Form,
    /// Formulário de filtros da busca.
    pub filter: Form,
    /// Filtros ativos aplicados na última consulta.
    pub filters: FilterParams,
    /// Linha de status / barra de mensagens (sucesso, erro ou dica). Um por vez.
    pub status: String,
    pub should_quit: bool,
    /// CNUC da unidade em edição (campo bloqueado, é a PK).
    pub editing_cnuc: String,
    /// CNUC pendente de confirmação de exclusão.
    pub delete_cnuc: String,
}

/// Rótulos dos campos do formulário de criação/edição, na ordem dos índices
/// usados em `create.fields[i]` (0 = CNUC, 2 = Data, 5 = KM, 10 = Área Total).
pub const CREATE_LABELS: &[&str] = &[
    "CNUC (12 chars)*",
    "Nome",
    "Data Criação (DD-MM-YYYY)",
    "Bioma",
    "Rodovia",
    "KM",
    "Cidade",
    "UF (2 chars)",
    "Descrição de Acesso",
    "Órgão Gestor",
    "Área Total",
];

/// Rótulos dos campos de filtro, na ordem dos índices em `filter.fields[i]`.
pub const FILTER_LABELS: &[&str] = &[
    "CNUC",
    "Nome",
    "Bioma",
    "Órgão Gestor",
    "Data Criação (DD-MM-YYYY)",
    "Rodovia",
    "Cidade",
    "UF",
    "KM",
];

impl App {
    /// Inicializa o estado e já faz a primeira carga das unidades.
    pub fn new() -> Self {
        let mut app = Self {
            screen: Screen::List,
            units: vec![],
            table_state: TableState::default(),
            create: Form::new(CREATE_LABELS.len()),
            filter: Form::new(FILTER_LABELS.len()),
            filters: FilterParams::default(),
            status: "Bem vindo ao Sistema de Gestão de Unidades de Conservação! :D".into(),
            should_quit: false,
            editing_cnuc: String::new(),
            delete_cnuc: String::new(),
        };

        let _ = app.fetch_units();
        app.status = "Bem vindo ao Sistema de Gestão de Unidades de Conservação! :D".into();

        app
    }

    /// Consulta a API com os filtros atuais e atualiza `units`/`status`.
    pub fn fetch_units(&mut self) -> Result<usize, String> {
        match api::list_unidades(&self.filters) {
            Ok(units) => {
                let count = units.len();
                self.units = units;

                if count == 0 {
                    self.table_state.select(None);
                    self.status = "Nenhuma unidade encontrada.".into();
                } else {
                    self.table_state.select(Some(0));
                    self.status =
                        format!("{count} unidade(s) encontrada(s). [Esc] Calcelar filtro");
                }

                Ok(count)
            }
            Err(e) => {
                self.units.clear();
                self.table_state.select(None);
                self.status = format!("Erro: {e}");

                Err(e)
            }
        }
    }

    /// Limpa todos os filtros e recarrega a lista completa.
    fn reset_filter(&mut self) {
        self.filters = FilterParams::default();

        self.screen = Screen::List;
        let _ = self.fetch_units();

        if self.units.is_empty() {
            return;
        }
        self.table_state.select(Some(0));
    }

    /// Ponto de entrada de teclado: despacha para o handler da tela ativa.
    pub fn handle_key(&mut self, key: KeyCode) {
        match self.screen {
            Screen::List => self.handle_list(key),
            Screen::Create => self.handle_create(key),
            Screen::Filter => self.handle_filter(key),
            Screen::Edit => self.handle_edit(key),
            Screen::DeleteConfirm => self.handle_delete_confirm(key),
        }
    }

    fn handle_list(&mut self, key: KeyCode) {
        match key {
            KeyCode::Char('q') => self.should_quit = true,
            KeyCode::Char('n') => {
                self.create.clear();
                self.screen = Screen::Create;
                self.status =
                    "Preencha os campos. [Tab] Próximo  [Enter] Criar  [Esc] Cancelar".into();
            }
            KeyCode::Char('/') => {
                self.screen = Screen::Filter;
                self.status =
                    "Filtrar: [Tab/Shift+Tab] Navegar  [Enter] Buscar  [Esc] Cancelar  │  Digite 'null' para buscar campos vazios".into();
            }
            KeyCode::Char('r') => {
                self.status = "Atualizando...".into();
                match self.fetch_units() {
                    Ok(count) => {
                        if count == 0 {
                            self.status = "Nenhuma unidade encontrada.".into();
                        } else {
                            self.status = format!("{count} unidade(s) encontrada(s).");
                        }
                    }
                    Err(e) => {
                        self.status = format!("Erro ao atualizar: {e}");
                    }
                }
            }
            KeyCode::Esc => {
                self.reset_filter();
                self.status =
                    "Bem vindo ao Sistema de Gestão de Unidades de Conservação! :D".into();
            }
            KeyCode::Char('e') => self.start_edit(),
            KeyCode::Char('d') => self.start_delete(),
            KeyCode::Down | KeyCode::Char('j') => self.move_down(),
            KeyCode::Up | KeyCode::Char('k') => self.move_up(),
            _ => {}
        }
    }

    fn move_down(&mut self) {
        if self.units.is_empty() {
            return;
        }
        let next = match self.table_state.selected() {
            Some(i) => (i + 1).min(self.units.len() - 1),
            None => 0,
        };
        self.table_state.select(Some(next));
    }

    fn move_up(&mut self) {
        if self.units.is_empty() {
            return;
        }
        let prev = match self.table_state.selected() {
            Some(0) | None => 0,
            Some(i) => i - 1,
        };
        self.table_state.select(Some(prev));
    }

    /// Abre a tela de edição preenchendo o formulário com a unidade selecionada.
    fn start_edit(&mut self) {
        let Some(unit) = self.table_state.selected().and_then(|i| self.units.get(i)) else {
            self.status = "Selecione uma unidade para editar.".into();
            return;
        };
        self.editing_cnuc = unit.cnuc.trim().to_string();
        self.create.clear();
        self.create.fields[0].value = self.editing_cnuc.clone();
        self.create.fields[1].value = unit.nome.clone().unwrap_or_default();
        self.create.fields[2].value = unit.data_criacao.clone().unwrap_or_default();
        self.create.fields[3].value = unit.bioma.clone().unwrap_or_default();
        self.create.fields[4].value = unit.rodovia.clone().unwrap_or_default();
        self.create.fields[5].value = unit.km.map(|v| v.to_string()).unwrap_or_default();
        self.create.fields[6].value = unit.cidade.clone().unwrap_or_default();
        self.create.fields[7].value = unit.uf.clone().unwrap_or_default();
        self.create.fields[8].value = unit.descricao_acesso.clone().unwrap_or_default();
        self.create.fields[9].value = unit.orgao_gestor.clone().unwrap_or_default();
        self.create.fields[10].value = unit.area_total_str().replace('-', "");
        self.create.focused = 1;
        self.screen = Screen::Edit;
        self.status = format!(
            "Editando '{}'  [Tab] Próximo  [Enter] Salvar  [Esc] Cancelar",
            self.editing_cnuc
        );
    }

    /// Abre o diálogo de confirmação de exclusão para a unidade selecionada.
    fn start_delete(&mut self) {
        let Some(unit) = self.table_state.selected().and_then(|i| self.units.get(i)) else {
            self.status = "Selecione uma unidade para excluir.".into();
            return;
        };
        self.delete_cnuc = unit.cnuc.trim().to_string();
        let nome = unit.nome.clone().unwrap_or_else(|| "—".into());
        self.screen = Screen::DeleteConfirm;
        self.status = format!(
            "Confirmar exclusão de '{}' ({})?  [s] Sim  [n/Esc] Não",
            self.delete_cnuc, nome
        );
    }

    fn handle_edit(&mut self, key: KeyCode) {
        match key {
            KeyCode::Esc => {
                self.screen = Screen::List;
                self.status = "Edição cancelada.".into();
            }
            KeyCode::Tab => self.create.next(),
            KeyCode::BackTab => self.create.prev(),
            KeyCode::Enter => self.submit_edit(),
            KeyCode::Char(c) => {
                // Lock CNUC field (index 0) in edit mode
                if self.create.focused != 0 {
                    self.create.fields[self.create.focused].push(c);
                }
            }
            KeyCode::Backspace => {
                if self.create.focused != 0 {
                    self.create.fields[self.create.focused].pop();
                }
            }
            _ => {}
        }
    }

    fn handle_delete_confirm(&mut self, key: KeyCode) {
        match key {
            KeyCode::Char('s') | KeyCode::Char('S') => {
                let cnuc = self.delete_cnuc.clone();
                self.status = "Excluindo...".into();
                match api::delete_unidade(&cnuc) {
                    Ok(_) => {
                        self.screen = Screen::List;
                        let _ = self.fetch_units();
                        self.status = format!("Unidade '{}' excluída com sucesso!", cnuc);
                    }
                    Err(e) => {
                        self.screen = Screen::List;
                        self.status = format!("Erro ao excluir: {e}");
                    }
                }
            }
            KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => {
                self.screen = Screen::List;
                self.status = "Exclusão cancelada.".into();
            }
            _ => {}
        }
    }

    fn handle_create(&mut self, key: KeyCode) {
        match key {
            KeyCode::Esc => {
                self.screen = Screen::List;
                self.status = "Criação cancelada.".into();
            }
            KeyCode::Tab => self.create.next(),
            KeyCode::BackTab => self.create.prev(),
            KeyCode::Enter => self.submit_create(),
            KeyCode::Char(c) => self.create.fields[self.create.focused].push(c),
            KeyCode::Backspace => self.create.fields[self.create.focused].pop(),
            _ => {}
        }
    }

    /// Valida os campos no cliente, monta o payload e chama POST `/unidades`.
    /// Erros da API caem em `status` via [`api::create_unidade`].
    fn submit_create(&mut self) {
        let cnuc = self.create.fields[0].value.clone();
        if cnuc.len() != 12 {
            self.status = "Erro: CNUC deve ter exatamente 12 caracteres!".into();
            return;
        }
        if let Err(e) = check_cnuc_digits(&cnuc) {
            self.status = e;
            return;
        }
        if let Err(e) = check_uf(&self.create.val(7)) {
            self.status = e;
            return;
        }

        let km = match self.create.val(5) {
            None => None,
            Some(s) => match s.parse::<i32>() {
                Ok(v) => Some(v),
                Err(_) => {
                    self.status = "Erro: KM deve ser um número inteiro (ex: 18)".into();
                    return;
                }
            },
        };

        let area_total = match self.create.val(10) {
            None => None,
            Some(s) => match s.parse::<f64>() {
                Ok(v) => Some(v),
                Err(_) => {
                    self.status = "Erro: Área Total deve ser um número (ex: 1234.56)".into();
                    return;
                }
            },
        };

        let payload = CreateUnidade {
            cnuc,
            nome: self.create.val(1),
            data_criacao: self.create.val(2),
            bioma: self.create.val(3),
            rodovia: self.create.val(4),
            km,
            cidade: self.create.val(6),
            uf: self.create.val(7),
            descricao_acesso: self.create.val(8),
            orgao_gestor: self.create.val(9),
            area_total,
        };

        self.status = "Enviando...".into();
        match api::create_unidade(&payload) {
            Ok(u) => {
                self.screen = Screen::List;
                let _ = self.fetch_units();
                self.status = format!("Unidade '{}' criada com sucesso!", u.cnuc);
            }
            Err(e) => {
                self.status = format!("Erro: {e}");
            }
        }
    }

    /// Monta o payload e chama PUT `/unidades/{cnuc}` (CNUC imutável).
    fn submit_edit(&mut self) {
        if let Err(e) = check_uf(&self.create.val(7)) {
            self.status = e;
            return;
        }

        let km = match self.create.val(5) {
            None => None,
            Some(s) => match s.parse::<i32>() {
                Ok(v) => Some(v),
                Err(_) => {
                    self.status = "Erro: KM deve ser um número inteiro (ex: 18)".into();
                    return;
                }
            },
        };

        let area_total = match self.create.val(10) {
            None => None,
            Some(s) => match s.parse::<f64>() {
                Ok(v) => Some(v),
                Err(_) => {
                    self.status = "Erro: Área Total deve ser um número (ex: 1234.56)".into();
                    return;
                }
            },
        };

        let payload = CreateUnidade {
            cnuc: self.editing_cnuc.clone(),
            nome: self.create.val(1),
            data_criacao: self.create.val(2),
            bioma: self.create.val(3),
            rodovia: self.create.val(4),
            km,
            cidade: self.create.val(6),
            uf: self.create.val(7),
            descricao_acesso: self.create.val(8),
            orgao_gestor: self.create.val(9),
            area_total,
        };

        self.status = "Atualizando...".into();
        let cnuc = self.editing_cnuc.clone();
        match api::update_unidade(&cnuc, &payload) {
            Ok(u) => {
                self.screen = Screen::List;
                let _ = self.fetch_units();
                self.status = format!("Unidade '{}' atualizada com sucesso!", u.cnuc);
            }
            Err(e) => {
                self.status = format!("Erro: {e}");
            }
        }
    }

    fn handle_filter(&mut self, key: KeyCode) {
        match key {
            KeyCode::Esc => {
                self.reset_filter();
                self.status = "Busca cancelada.".into();
            }
            KeyCode::Tab => self.filter.next(),
            KeyCode::BackTab => self.filter.prev(),
            KeyCode::Enter => self.submit_filter(),
            KeyCode::Char(c) => self.filter.fields[self.filter.focused].push(c),
            KeyCode::Backspace => self.filter.fields[self.filter.focused].pop(),
            _ => {}
        }
    }

    /// Coleta os campos de filtro e dispara a consulta via [`Self::fetch_units`].
    fn submit_filter(&mut self) {
        if let Some(cnuc) = self.filter.val(0) {
            if let Err(e) = check_cnuc_digits(&cnuc) {
                self.status = e;
                return;
            }
        }
        if let Err(e) = check_uf(&self.filter.val(7)) {
            self.status = e;
            return;
        }

        self.filters = FilterParams {
            cnuc: self.filter.val(0),
            nome: self.filter.val(1),
            bioma: self.filter.val(2),
            orgao_gestor: self.filter.val(3),
            data_criacao: self.filter.val(4),
            rodovia: self.filter.val(5),
            cidade: self.filter.val(6),
            uf: self.filter.val(7),
            km: self.filter.val(8),
        };
        self.status = "Buscando...".into();

        match self.fetch_units() {
            Ok(count) => {
                if count == 0 {
                    self.status = "Nenhuma unidade encontrada.".into();
                } else {
                    self.status =
                        format!("{count} unidade(s) encontrada(s). [Esc] - Cancelar busca");
                }
            }
            Err(e) => {
                self.status = format!("Erro ao filtrar: {e}");
                return;
            }
        }

        self.screen = Screen::List;
    }
}
