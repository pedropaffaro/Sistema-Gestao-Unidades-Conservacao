use ratatui::{
    layout::{Constraint, Layout, Position, Rect},
    style::{Color, Modifier, Style, Stylize},
    text::{Line, Span},
    widgets::{Block, Borders, Cell, Paragraph, Row, Table, Wrap},
    Frame,
};

use crate::app::{App, Screen, CREATE_LABELS, FILTER_LABELS};

const CYAN: Color = Color::Cyan;
const GREEN: Color = Color::Green;
const YELLOW: Color = Color::Yellow;
const DARK_GRAY: Color = Color::DarkGray;
const RED: Color = Color::Red;

pub fn render(frame: &mut Frame, app: &mut App) {
    let [main, status_bar] =
        Layout::vertical([Constraint::Min(3), Constraint::Length(1)]).areas(frame.area());

    match app.screen {
        Screen::List => render_list(frame, app, main),
        Screen::Create => render_form(
            frame,
            app,
            main,
            " Nova Unidade de Conservação ",
            &app.create.fields.clone(),
            CREATE_LABELS,
            app.create.focused,
        ),
        Screen::Filter => render_form(
            frame,
            app,
            main,
            " Filtrar Unidades ",
            &app.filter.fields.clone(),
            FILTER_LABELS,
            app.filter.focused,
        ),
    }

    render_status(frame, app, status_bar);
}

fn render_list(frame: &mut Frame, app: &mut App, area: Rect) {
    let detail_height = 6u16;
    let [table_area, detail_area] =
        Layout::vertical([Constraint::Min(3), Constraint::Length(detail_height)]).areas(area);

    render_table(frame, app, table_area);
    render_detail(frame, app, detail_area);
}

fn render_table(frame: &mut Frame, app: &mut App, area: Rect) {
    let filter_label = build_filter_label(app);
    let title = if filter_label.is_empty() {
        " Unidades de Conservação ".to_string()
    } else {
        format!(" Unidades de Conservação  [{}] ", filter_label)
    };

    let header = Row::new([
        Cell::from("CNUC").style(Style::new().fg(CYAN).bold()),
        Cell::from("Nome").style(Style::new().fg(CYAN).bold()),
        Cell::from("Bioma").style(Style::new().fg(CYAN).bold()),
        Cell::from("Órgão Gestor").style(Style::new().fg(CYAN).bold()),
        Cell::from("Data Criação").style(Style::new().fg(CYAN).bold()),
        Cell::from("Área Total").style(Style::new().fg(CYAN).bold()),
    ]);

    let rows = app.units.iter().map(|u| {
        Row::new([
            Cell::from(u.cnuc.trim().to_string()),
            Cell::from(u.nome.clone().unwrap_or_default()),
            Cell::from(u.bioma.clone().unwrap_or_default()),
            Cell::from(u.orgao_gestor.clone().unwrap_or_default()),
            Cell::from(u.data_criacao.clone().unwrap_or_default()),
            Cell::from(u.area_total_str()),
        ])
    });

    let widths = [
        Constraint::Length(12),
        Constraint::Min(18),
        Constraint::Length(14),
        Constraint::Min(18),
        Constraint::Length(12),
        Constraint::Length(12),
    ];

    let table = Table::new(rows, widths)
        .header(header.bottom_margin(0))
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title(title)
                .title_style(Style::new().fg(CYAN).bold()),
        )
        .row_highlight_style(Style::new().fg(Color::Black).bg(YELLOW).bold())
        .highlight_symbol("► ");

    frame.render_stateful_widget(table, area, &mut app.table_state);
}

fn render_detail(frame: &mut Frame, app: &App, area: Rect) {
    let block = Block::default()
        .borders(Borders::ALL)
        .title(" Detalhes ")
        .title_style(Style::new().fg(CYAN));

    let content = match app.table_state.selected().and_then(|i| app.units.get(i)) {
        None => Paragraph::new("Nenhuma unidade selecionada. Use ↑↓ ou j/k para navegar.")
            .style(Style::new().fg(DARK_GRAY))
            .block(block),
        Some(u) => {
            let lines = vec![
                Line::from(vec![
                    Span::styled("CNUC: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.cnuc.trim()),
                    Span::raw("   "),
                    Span::styled("Nome: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.nome.as_deref().unwrap_or("—")),
                ]),
                Line::from(vec![
                    Span::styled("Bioma: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.bioma.as_deref().unwrap_or("—")),
                    Span::raw("   "),
                    Span::styled("Órgão Gestor: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.orgao_gestor.as_deref().unwrap_or("—")),
                ]),
                Line::from(vec![
                    Span::styled("Data Criação: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.data_criacao.as_deref().unwrap_or("—")),
                    Span::raw("   "),
                    Span::styled("Área Total: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.area_total_str()),
                ]),
                Line::from(vec![
                    Span::styled("Endereço: ", Style::new().fg(DARK_GRAY)),
                    Span::raw(u.endereco.as_deref().unwrap_or("—")),
                ]),
            ];
            Paragraph::new(lines).block(block).wrap(Wrap { trim: true })
        }
    };

    frame.render_widget(content, area);
}

fn render_form(
    frame: &mut Frame,
    app: &mut App,
    area: Rect,
    title: &str,
    fields: &[crate::app::Input],
    labels: &[&str],
    focused: usize,
) {
    let block = Block::default()
        .borders(Borders::ALL)
        .title(title)
        .title_style(Style::new().fg(CYAN).bold());

    let inner = block.inner(area);
    frame.render_widget(block, area);

    let max_label_w = labels.iter().map(|l| l.chars().count()).max().unwrap_or(0) as u16;

    // left_pad(2) + label + ": "(2) + input
    let input_start_x = inner.x + 2 + max_label_w + 2;

    for (i, (field, &label)) in fields.iter().zip(labels.iter()).enumerate() {
        let row_y = inner.y + 1 + i as u16;
        if row_y >= inner.y + inner.height.saturating_sub(1) {
            break;
        }

        let is_focused = i == focused;

        let label_style = if is_focused {
            Style::new().fg(GREEN).add_modifier(Modifier::BOLD)
        } else {
            Style::new().fg(DARK_GRAY)
        };

        let input_style = if is_focused {
            Style::new().fg(Color::White).bg(Color::DarkGray)
        } else {
            Style::new().fg(Color::Gray)
        };

        // Render label (right-padded to max_label_w + ": ")
        let label_text = format!("{:<width$}: ", label, width = max_label_w as usize);
        let label_rect = Rect {
            x: inner.x + 2,
            y: row_y,
            width: (max_label_w + 2).min(inner.width.saturating_sub(2)),
            height: 1,
        };
        frame.render_widget(Paragraph::new(label_text).style(label_style), label_rect);

        // Render input box
        let input_w = inner
            .width
            .saturating_sub(input_start_x - inner.x)
            .saturating_sub(2);

        if input_w > 0 && input_start_x < inner.x + inner.width {
            let input_rect = Rect {
                x: input_start_x,
                y: row_y,
                width: input_w,
                height: 1,
            };

            let display = format!("{:<width$}", field.value, width = input_w as usize);
            let display = if display.chars().count() > input_w as usize {
                display.chars().take(input_w as usize).collect::<String>()
            } else {
                display
            };

            frame.render_widget(Paragraph::new(display).style(input_style), input_rect);

            if is_focused {
                let cursor_x = input_start_x + field.value.chars().count() as u16;
                if cursor_x < input_start_x + input_w {
                    frame.set_cursor_position(Position::new(cursor_x, row_y));
                }
            }
        }
    }

    // Key hint at the bottom of the form
    let hint = match app.screen {
        Screen::Create => "[Tab] Próximo  [Shift+Tab] Anterior  [Enter] Criar  [Esc] Cancelar",
        Screen::Filter => "[Tab] Próximo  [Shift+Tab] Anterior  [Enter] Buscar  [Esc] Cancelar",
        Screen::List => "",
    };
    let hint_y = inner.y + inner.height.saturating_sub(1);
    if hint_y > inner.y && !hint.is_empty() {
        frame.render_widget(
            Paragraph::new(hint).style(Style::new().fg(DARK_GRAY)),
            Rect {
                x: inner.x + 1,
                y: hint_y,
                width: inner.width.saturating_sub(2),
                height: 1,
            },
        );
    }
}

fn render_status(frame: &mut Frame, app: &App, area: Rect) {
    let style = if app.status.starts_with("Erro") || app.status.starts_with("Falha") {
        Style::new().fg(RED)
    } else if app.status.contains("sucesso") || app.status.contains("encontrada") {
        Style::new().fg(GREEN)
    } else if app.status.starts_with("Enviando")
        || app.status.starts_with("Atualizando")
        || app.status.starts_with("Buscando")
    {
        Style::new().fg(YELLOW)
    } else {
        Style::new().fg(DARK_GRAY)
    };

    // Show key hints for list screen inline with status
    let text = if app.screen == Screen::List {
        format!(
            " {}  │  [n] Nova  [/] Filtrar  [r] Atualizar  [j/k ↑↓] Navegar  [q] Sair",
            app.status
        )
    } else {
        format!(" {}", app.status)
    };

    frame.render_widget(Paragraph::new(text).style(style), area);
}

fn build_filter_label(app: &App) -> String {
    let mut parts = vec![];
    if let Some(v) = &app.filters.nome {
        parts.push(format!("nome={v}"));
    }
    if let Some(v) = &app.filters.bioma {
        parts.push(format!("bioma={v}"));
    }
    if let Some(v) = &app.filters.orgao_gestor {
        parts.push(format!("órgão={v}"));
    }
    if let Some(v) = &app.filters.data_criacao {
        parts.push(format!("data={v}"));
    }
    parts.join(", ")
}
