use crossterm::event::KeyCode;
use ratatui::widgets::TableState;

use crate::api::{self, CreateUnidade, FilterParams, Unidade};

#[derive(PartialEq, Eq)]
pub enum Screen {
    List,
    Create,
    Filter,
}

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

    pub fn val(&self, i: usize) -> Option<String> {
        let v = &self.fields[i].value;
        if v.is_empty() {
            None
        } else {
            Some(v.clone())
        }
    }
}

pub struct App {
    pub screen: Screen,
    pub units: Vec<Unidade>,
    pub table_state: TableState,
    pub create: Form,
    pub filter: Form,
    pub filters: FilterParams,
    pub status: String,
    pub should_quit: bool,
}

pub const CREATE_LABELS: &[&str] = &[
    "CNUC (12 chars)*",
    "Nome",
    "Data Criação (YYYY-MM-DD)",
    "Bioma",
    "Endereço",
    "Órgão Gestor",
    "Área Total",
];

pub const FILTER_LABELS: &[&str] = &["Nome", "Bioma", "Órgão Gestor", "Data Criação (YYYY-MM-DD)"];

impl App {
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
        };

        let _ = app.fetch_units();
        app.status = "Bem vindo ao Sistema de Gestão de Unidades de Conservação! :D".into();

        app
    }

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

    fn reset_filter(&mut self) {
        self.filters = FilterParams {
            nome: None,
            bioma: None,
            orgao_gestor: None,
            data_criacao: None,
        };

        self.screen = Screen::List;
        let _ = self.fetch_units();

        if self.units.is_empty() {
            return;
        }
        self.table_state.select(Some(0));
    }

    pub fn handle_key(&mut self, key: KeyCode) {
        match self.screen {
            Screen::List => self.handle_list(key),
            Screen::Create => self.handle_create(key),
            Screen::Filter => self.handle_filter(key),
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
                    "Preencha os filtros. [Tab] Próximo  [Enter] Buscar  [Esc] Cancelar".into();
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

    fn submit_create(&mut self) {
        let cnuc = self.create.fields[0].value.clone();
        if cnuc.len() != 12 {
            self.status = "Erro: CNUC deve ter exatamente 12 caracteres!".into();
            return;
        }

        let area_total = match self.create.val(6) {
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
            endereco: self.create.val(4),
            orgao_gestor: self.create.val(5),
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

    fn submit_filter(&mut self) {
        self.filters = FilterParams {
            nome: self.filter.val(0),
            bioma: self.filter.val(1),
            orgao_gestor: self.filter.val(2),
            data_criacao: self.filter.val(3),
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
                self.status = format!("Erro ao atualizar: {e}");
                return;
            }
        }

        self.screen = Screen::List;
    }
}
