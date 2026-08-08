$(function () {

    $.validator.addMethod("abonoValido", function (value, element) {

        var saldoAnterior = parseFloat($("#SaldoAnterior").val()) || 0;
        var abono = parseFloat(value) || 0;

        return abono <= saldoAnterior;

    }, "El abono no puede ser mayor al saldo anterior");


    $("#formAbono").validate({
        rules: {
            IdCompra: {
                required: true
            },
            Abono: {
                required: true,
                number: true,
                min: 0.01,
                abonoValido: true
            }
        },
        messages: {
            IdCompra: {
                required: "Campo obligatorio"
            },
            Abono: {
                required: "Campo obligatorio",
                number: "Debe digitar un monto válido",
                min: "El monto debe ser mayor a cero"
            }
        },
        errorElement: "span",
        errorPlacement: function (error, element) {
            error.addClass("text-white small d-block mt-1");
            error.insertAfter(element);
        },
        highlight: function (element) {
            $(element).addClass("is-invalid");
        },
        unhighlight: function (element) {
            $(element)
                .removeClass("is-invalid")
                .addClass("is-valid");
        },
        submitHandler: function (form) {
            form.submit();
        }
    });


    $("#IdCompra").change(function () {

        var idCompra = $(this).val();

        $("#Abono").val("");

        if (idCompra == "") {
            $("#SaldoAnterior").val("");
            return;
        }

        $.ajax({
            url: "/Home/ConsultarSaldoCompra",
            type: "GET",
            data: {
                idCompra: idCompra
            },
            success: function (response) {

                $("#SaldoAnterior").val(
                    response.saldoAnterior
                );
            },
            error: function () {

                $("#SaldoAnterior").val("");
            }
        });

    });

});