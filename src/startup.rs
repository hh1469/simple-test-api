use std::{net::TcpListener, sync::Mutex};

use actix_web::{dev::Server, web, App, HttpServer};

pub fn run(listener: TcpListener) -> std::io::Result<Server> {
    // let connection = web::Data::new(pool);

    let db = crate::mem_db::MemDB { data: vec![] };
    let m = web::Data::new(Mutex::new(db));

    let server = HttpServer::new(move || {
        App::new()
            .app_data(m.clone())
            .route(
                "/api/transactions/GetVoucher",
                web::get().to(crate::routes::get_voucher),
            )
            .route(
                "/api/transactions/SyncVoucher",
                web::get().to(crate::routes::sync_voucher),
            )
            .route(
                "/api/transactions/SyncVoucherCashDesk",
                web::get().to(crate::routes::sync_voucher_cash_desk),
            )
        // .app_data(connection.clone())
    })
    .listen(listener)?
    .run();
    // no await here
    Ok(server)
}
