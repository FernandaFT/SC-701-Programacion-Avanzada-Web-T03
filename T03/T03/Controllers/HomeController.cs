using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using System.Net;
using T03.Models;

namespace T03.Controllers
{
    public class HomeController(
        IHttpClientFactory _http,
        IConfiguration _config) : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        [HttpGet]
        public IActionResult Registrar()
        {
            using var client = _http.CreateClient();
            var url = _config["Valores:UrlApi"] + "Home/ConsultarComprasAPI";
            var response = client.GetAsync(url).Result;

            var model = new RegistroModel();
            CargarCompras(model);

            if (response.StatusCode == HttpStatusCode.OK)
            {
                var compras = response.Content.ReadFromJsonAsync<List<CompraModel>>().Result;

                if (compras != null)
                {
                    model.ComprasPendientes = compras
                        .Select(x => new SelectListItem
                        {
                            Value = x.IdCompra.ToString(),
                            Text = $"Compra #{x.IdCompra}"
                        })
                        .ToList();
                }

                return View(model);
            }

            throw new Exception("Error al consultar las compras");
        }

        [HttpPost]
        public IActionResult Registrar(RegistroModel model)
        {
            using var client = _http.CreateClient();
            var url = _config["Valores:UrlApi"] + "Home/RegistrarAbonoAPI";
            var response = client.PostAsJsonAsync(url, model).Result;

            if (response.StatusCode == HttpStatusCode.OK)
            {
                TempData["Mensaje"] = "El abono se registró correctamente.";
                TempData["TipoMensaje"] = "success";

                return RedirectToAction("Registrar");
            }
            else if (response.StatusCode == HttpStatusCode.BadRequest || response.StatusCode == HttpStatusCode.NotFound)
            {
                ViewBag.Mensaje = response.Content.ReadAsStringAsync().Result;
                CargarCompras(model);

                return View(model);
            }

            throw new Exception("Error al registrar el abono");
        }

        private void CargarCompras(RegistroModel model)
        {
            using var client = _http.CreateClient();
            var url = _config["Valores:UrlApi"] + "Home/ConsultarComprasAPI";
            var response = client.GetAsync(url).Result;

            if (response.StatusCode == HttpStatusCode.OK)
            {
                var compras = response.Content.ReadFromJsonAsync<List<CompraModel>>().Result;

                if (compras != null)
                {
                    model.ComprasPendientes = compras
                        .Select(x => new SelectListItem
                        {
                            Value = x.IdCompra.ToString(),
                            Text = $"Compra #{x.IdCompra}"
                        })
                        .ToList();
                }
            }
        }

        [HttpGet]
        public IActionResult ConsultarSaldoCompra(long idCompra)
        {
            using var client = _http.CreateClient();

            var url = _config["Valores:UrlApi"] + "Home/ConsultarSaldoCompraAPI?idCompra=" + idCompra;

            var response = client.GetAsync(url).Result;

            if (response.StatusCode == HttpStatusCode.OK)
            {
                var saldo = response.Content.ReadFromJsonAsync<SaldoCompraModel>().Result;

                return Json(saldo);
            }

            return Json(new
            {
                saldoAnterior = 0
            });
        }


        public IActionResult Consultar()
        {
            using var client = _http.CreateClient();
            var url = _config["Valores:UrlApi"] + "Home/ConsultarDetalleComprasAPI";
            var response = client.GetAsync(url).Result;

            if (response.StatusCode == HttpStatusCode.OK)
            {
                var compras = response.Content.ReadFromJsonAsync<List<ConsultarAbonoModel>>().Result;

                return View(compras);
            }

            throw new Exception("Error al consultar las compras");
        }
    }
}
