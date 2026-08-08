namespace T03.Models
{
    public class ConsultarAbonoModel
    {
        public long IdCompra { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public decimal Saldo { get; set; }
        public string Estado { get; set; } = string.Empty;
    }
}
