using Dapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using System.Data;
using T03_API.Models;

namespace T03_API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class HomeController (IConfiguration _config) : ControllerBase
    {

        [HttpGet("ConsultarComprasAPI")]
        public IActionResult ConsultarComprasAPI()
        {
            using var context = new SqlConnection(_config["ConnectionStrings:DefaultConnection"]);

            var response = context.Query<CompraModel>("spConsultarCompras").ToList();

            return Ok(response);
        }

        [HttpGet("ConsultarSaldoCompraAPI")]
        public IActionResult ConsultarSaldoCompraAPI(long idCompra)
        {
            using var context = new SqlConnection(_config["ConnectionStrings:DefaultConnection"]);

            var parameters = new DynamicParameters();
            parameters.Add("@IdCompra", idCompra);

            var response = context.QueryFirstOrDefault<SaldoCompraModel>("spConsultarSaldoCompra",parameters);

            if (response == null)
            {
                return NotFound("No se encontró la compra");
            }

            return Ok(response);
        }

        [HttpPost("RegistrarAbonoAPI")]
        public IActionResult RegistrarAbonoAPI(RegistroAbonoModel model)
        {
            try
            {
                using var context = new SqlConnection(_config["ConnectionStrings:DefaultConnection"]);

                var parameters = new DynamicParameters();
                parameters.Add("@IdCompra", model.IdCompra);
                parameters.Add("@Monto", model.Abono);

                var response = context.QueryFirstOrDefault<ResultadoAbonoModel>("spRegistrarAbono",parameters);

                if (response == null)
                {
                    return BadRequest("No se pudo registrar el abono.");
                }

                return Ok(response);
            }
            catch (SqlException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("ConsultarDetalleComprasAPI")]
        public IActionResult ConsultarDetalleComprasAPI()
        {
            using var context = new SqlConnection(_config["ConnectionStrings:DefaultConnection"]);

            var response = context.Query<ConsultarAbonoModel>("spConsultarDetalleCompras").ToList();

            return Ok(response);
        }
    }
}
