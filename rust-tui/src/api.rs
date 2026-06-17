use serde::{Deserialize, Serialize};
use std::time::Duration;

const BASE_URL: &str = "http://localhost:8000";
const TIMEOUT: Duration = Duration::from_secs(10);

#[derive(Debug, Clone, Deserialize)]
pub struct Unidade {
    pub cnuc: String,
    pub nome: Option<String>,
    pub data_criacao: Option<String>,
    pub bioma: Option<String>,
    pub endereco: Option<String>,
    pub orgao_gestor: Option<String>,
    // Pydantic v2 may serialize Decimal as string or number; accept both
    pub area_total: Option<serde_json::Value>,
}

impl Unidade {
    pub fn area_total_str(&self) -> String {
        match &self.area_total {
            None => "-".into(),
            Some(serde_json::Value::String(s)) => s.clone(),
            Some(serde_json::Value::Number(n)) => n.to_string(),
            Some(v) => v.to_string(),
        }
    }
}

#[derive(Debug, Serialize)]
pub struct CreateUnidade {
    pub cnuc: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub nome: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub data_criacao: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bioma: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub endereco: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub orgao_gestor: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub area_total: Option<f64>,
}

#[derive(Debug, Default, Clone)]
pub struct FilterParams {
    pub nome: Option<String>,
    pub bioma: Option<String>,
    pub orgao_gestor: Option<String>,
    pub data_criacao: Option<String>,
}

fn extract_error(body: &str, use_msg: bool) -> String {
    #[derive(Deserialize)]
    struct PydanticErrorDetail {
        msg: String,
    }

    #[derive(Deserialize)]
    struct ApiError {
        msg: Option<serde_json::Value>,
        detail: Option<serde_json::Value>,
    }

    serde_json::from_str::<ApiError>(body)
        .ok()
        .and_then(|e| {
            if use_msg {
                e.detail
                    .and_then(|v| serde_json::from_value::<Vec<PydanticErrorDetail>>(v).ok())
                    .and_then(|list| list.into_iter().next()) // .next() em iterator consome o primeiro item (equivalente ao .first())
                    .map(|err| err.msg)
                    .or(match e.msg {
                        Some(serde_json::Value::String(s)) => Some(s),
                        _ => None,
                    })
            } else {
                e.detail.map(|detail_val| match detail_val {
                    serde_json::Value::String(s) => s,
                    v => v.to_string(),
                })
            }
        })
        .unwrap_or_else(|| body.to_string())
}

pub fn list_unidades(filters: &FilterParams) -> Result<Vec<Unidade>, String> {
    let client = reqwest::blocking::Client::new();
    let mut req = client.get(format!("{BASE_URL}/unidades")).timeout(TIMEOUT);

    if let Some(v) = &filters.nome {
        if !v.is_empty() {
            req = req.query(&[("nome", v.as_str())]);
        }
    }
    if let Some(v) = &filters.bioma {
        if !v.is_empty() {
            req = req.query(&[("bioma", v.as_str())]);
        }
    }
    if let Some(v) = &filters.orgao_gestor {
        if !v.is_empty() {
            req = req.query(&[("orgao_gestor", v.as_str())]);
        }
    }
    if let Some(v) = &filters.data_criacao {
        if !v.is_empty() {
            req = req.query(&[("data_criacao", v.as_str())]);
        }
    }

    let resp = req.send().map_err(|e| format!("Falha na conexão: {e}"))?;

    // 404 means no results, not an error
    if resp.status().as_u16() == 404 {
        return Ok(vec![]);
    }

    if !resp.status().is_success() {
        let status = resp.status();
        let body = resp.text().unwrap_or_default();

        if status.as_u16() == 422 {
            return Err(extract_error(&body, true));
        } else {
            return Err(format!("HTTP {status}: {}", extract_error(&body, false)));
        }
    }

    resp.json::<Vec<Unidade>>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}

pub fn create_unidade(payload: &CreateUnidade) -> Result<Unidade, String> {
    let client = reqwest::blocking::Client::new();
    let resp = client
        .post(format!("{BASE_URL}/unidades"))
        .json(payload)
        .timeout(TIMEOUT)
        .send()
        .map_err(|e| format!("Falha na conexão: {e}"))?;

    if !resp.status().is_success() {
        let status = resp.status();
        let body = resp.text().unwrap_or_default();

        if status.as_u16() == 422 {
            return Err(extract_error(&body, true));
        } else {
            return Err(format!("HTTP {status}: {}", extract_error(&body, false)));
        }
    }

    resp.json::<Unidade>()
        .map_err(|e| format!("Erro ao parsear resposta: {e}"))
}
