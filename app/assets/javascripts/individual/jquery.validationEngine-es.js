(function ($) {
  $.fn.validationEngineLanguage = function () {};
  $.validationEngineLanguage = {
    newLang: function () {
      $.validationEngineLanguage.allRules = {
        "required": { // Add your regex rules here, you can take telephone as an example
          "regex": "none",
          "alertText": "* Este campo es obligatorio",
          "alertTextCheckboxMultiple": "* Por favor seleccione una opción",
          "alertTextCheckboxe": "* Este checkbox es obligatorio",
          "alertTextDateRange": "* Ambos rangos son obligatorios"
        },
        "requiredInFunction": {
          "func": function (field, rules, i, options) {
            return (field.val() == "test") ? true : false;
          },
          "alertText": "* Field must equal test"
        },
        "dateRange": {
          "regex": "none",
          "alertText": "* Inválido ",
          "alertText2": "Rango de días"
        },
        "dateTimeRange": {
          "regex": "none",
          "alertText": "* Inválido ",
          "alertText2": "Rango de tiempo"
        },
        "minSize": {
          "regex": "none",
          "alertText": "* Mínimo ",
          "alertText2": " caracteres permitidos"
        },
        "maxSize": {
          "regex": "none",
          "alertText": "* Máximo ",
          "alertText2": " caracteres no permitidos"
        },
        "groupRequired": {
          "regex": "none",
          "alertText": "* Debe rellenar uno de los siguientes campos"
        },
        "min": {
          "regex": "none",
          "alertText": "* El valor mínimo es "
        },
        "max": {
          "regex": "none",
          "alertText": "* El valor máximo es "
        },
        "past": {
          "regex": "none",
          "alertText": "* Fecha anterior a "
        },
        "future": {
          "regex": "none",
          "alertText": "* Fecha pasada "
        },
        "maxCheckbox": {
          "regex": "none",
          "alertText": "* Máximo ",
          "alertText2": " opciones permitidas"
        },
        "minCheckbox": {
          "regex": "none",
          "alertText": "* Por favor seleccione ",
          "alertText2": " opciones"
        },
        "equals": {
          "regex": "none",
          "alertText": "* Los campos que no coinciden"
        },
        "creditCard": {
          "regex": "none",
          "alertText": "* Número de tarjeta de crédito inválido"
        },
        "phone": {
          // credit: jquery.h5validate.js / orefalo
          "regex": /^([\+][0-9]{1,3}[\ \.\-])?([\(]{1}[0-9]{2,6}[\)])?([0-9\ \.\-\/]{3,20})((x|ext|extension)[\ ]?[0-9]{1,4})?$/,
          "alertText": "* Número de teléfono inválido"
        },
        "email": {
          // HTML5 compatible email regex ( http://www.whatwg.org/specs/web-apps/current-work/multipage/states-of-the-type-attribute.html#  e-mail-state-%28type=email%29 )
          "regex": /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/,
          "alertText": "* Dirección de correo electrónico inválida"
        },
        "integer": {
          "regex": /^[\-\+]?\d+$/,
          "alertText": "* Número inválido"
        },
        "number": {
          // Number, including positive, negative, and floating decimal. credit: orefalo
          "regex": /^[\-\+]?(([0-9]+)([\.,]([0-9]+))?|([\.,]([0-9]+))?)$/,
          "alertText": "* Número decimal inválido"
        },
        "date": {
          "regex": /^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$/,
          "alertText": "* Fecha no válida, debe estar en formato YYYY-MM-DD"
        },
        "ipv4": {
          "regex": /^((([01]?[0-9]{1,2})|(2[0-4][0-9])|(25[0-5]))[.]){3}(([0-1]?[0-9]{1,2})|(2[0-4][0-9])|(25[0-5]))$/,
          "alertText": "* Dirección IP no válida"
        },
        "url": {
          "regex": /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i,
          "alertText": "* URL no válida"
        },
        "onlyNumberSp": {
          "regex": /^[0-9\ ]+$/,
          "alertText": "* Sólo números"
        },
        "onlyLetterSp": {
          "regex": /^[a-zA-Z\ \']+$/,
          "alertText": "* Sólo letras"
        },
        "onlyLetterNumber": {
          "regex": /^[0-9a-zA-Z]+$/,
          "alertText": "* No se permiten los caracteres especiales"
        },
        // --- CUSTOM RULES -- Those are specific to the demos, they can be removed or changed to your likings
        "postalCodeCA": {
          "regex": /^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ] ?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$/i,
          "alertText": "* Código postal no válido (por ejemplo: 07015)",
        },
        //tls warning:homegrown not fielded
        "dateFormat":{
          "regex": /^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])$|^(?:(?:(?:0?[13578]|1[02])(\/|-)31)|(?:(?:0?[1,3-9]|1[0-2])(\/|-)(?:29|30)))(\/|-)(?:[1-9]\d\d\d|\d[1-9]\d\d|\d\d[1-9]\d|\d\d\d[1-9])$|^(?:(?:0?[1-9]|1[0-2])(\/|-)(?:0?[1-9]|1\d|2[0-8]))(\/|-)(?:[1-9]\d\d\d|\d[1-9]\d\d|\d\d[1-9]\d|\d\d\d[1-9])$|^(0?2(\/|-)29)(\/|-)(?:(?:0[48]00|[13579][26]00|[2468][048]00)|(?:\d\d)?(?:0[48]|[2468][048]|[13579][26]))$/,
          "alertText": "* Fecha no válida"
        },
        //tls warning:homegrown not fielded
        "dateTimeFormat": {
          "regex": /^\d{4}[\/\-](0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])\s+(1[012]|0?[1-9]){1}:(0?[1-5]|[0-6][0-9]){1}:(0?[0-6]|[0-6][0-9]){1}\s+(am|pm|AM|PM){1}$|^(?:(?:(?:0?[13578]|1[02])(\/|-)31)|(?:(?:0?[1,3-9]|1[0-2])(\/|-)(?:29|30)))(\/|-)(?:[1-9]\d\d\d|\d[1-9]\d\d|\d\d[1-9]\d|\d\d\d[1-9])$|^((1[012]|0?[1-9]){1}\/(0?[1-9]|[12][0-9]|3[01]){1}\/\d{2,4}\s+(1[012]|0?[1-9]){1}:(0?[1-5]|[0-6][0-9]){1}:(0?[0-6]|[0-6][0-9]){1}\s+(am|pm|AM|PM){1})$/,
          "alertText": "* Fecha o Formato de fecha inválida",
          "alertText2": "Formato esperado: ",
          "alertText3": "mm/dd/yyyy hh:mm:ss AM|PM or ",
          "alertText4": "yyyy-mm-dd hh:mm:ss AM|PM"
        }
      };
    }
  };
  $.validationEngineLanguage.newLang();
})(jQuery);