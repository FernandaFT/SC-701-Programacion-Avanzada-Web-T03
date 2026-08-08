namespace T03_API.Models
{
    public class ResultadoAbonoModel
    {
        public long IdCompra { get; set; }
        public decimal SaldoAnterior { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}
