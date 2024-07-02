use std::sync::Mutex;

use actix_web::{web, HttpRequest, HttpResponse, Responder};
use serde::Deserialize;

use crate::mem_db::MemDB;

#[derive(Debug, Deserialize)]
struct Params {
    #[serde(rename(deserialize = "voucherBarcode"))]
    voucher_barcode: String,
}

pub async fn get_voucher(req: HttpRequest, data: web::Data<Mutex<MemDB>>) -> impl Responder {
    let params = match web::Query::<Params>::from_query(req.query_string()) {
        Ok(p) => p,
        Err(e) => {
            log::error!("{}", e);
            return HttpResponse::BadRequest();
        }
    };

    let data = data.lock();
    let d = match data {
        Ok(d) => d,
        Err(e) => {
            log::error!("{}", e);
            return HttpResponse::NotFound();
        }
    };

    if d.data.contains(&params.voucher_barcode) {
        log::info!("already found: {}", params.voucher_barcode);
        return HttpResponse::Ok();
    }

    log::info!("not found: {}", params.voucher_barcode);
    HttpResponse::NotFound()
}
