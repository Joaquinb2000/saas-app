const GetURLParameter = (sParam) => {
    let sPageURL = window.location.search.substring(1);
    let sURLVariables = sPageURL.split('&');

    for (let i = 0; i < sURLVariables.length; i++)
    {
      var sParameterName = sURLVariables[i].split('=');
      if (sParameterName[0] == sParam)
      {
          console.log(sParameterName[1])
          return sParameterName[1];
      }
    }
  };

$(document).ready(()=>{
    let show_error, stripeResponseHandler, submitHandler;

    submitHandler = (event) =>{
        let $form = $(event.target);
        $form.find("input[type=submit]").prop("disabled", true)

        //If stripe was initialized correctly this will create a token using the credit card info
        if(Stripe){
            Stripe.card.createToken($form, stripeResponseHandler)
        }
        else{
            show_error("Failed to load card processsing functionality. Please reload this page in your browser.")
        }
        return false;
    }

    $(".cc_form").on("submit", submitHandler)

    handlePlanChange = (plan_type, target) =>{
        let form= $(target)
        let card_fields = $("#card_info")

        if(plan_type == undefined) {
            plan_type = $('#tenant_plan :selected').val();
        }

        if(plan_type === 'premium'){
            $("[data-stripe]").prop("required", true)
            form.off('submit')
            form.on("submit", submitHandler)
            card_fields.show()
        }
        else{
            $("[data-stripe]").removeProp("required")
            form.off('submit')
            card_fields.hide()
        }
    }


    handlePlanChange("Select a plan", ".cc_form")
    $("#tenant_plan").on("change", (e) => {
        handlePlanChange(e.target.value, '.cc_form')
    })

    handlePlanChange(GetURLParameter('plan'), ".cc_form");

    stripeResponseHandler = (status, response) => {
        let token, $form;
        $form = $('.cc_form');

        if (response.error) {
            console.log(response.error.message);
            show_error(response.error.message);
            $form.find("input[type=submit]").prop("disabled", false);
        }
        else {
            token = response.id;
            $form.append($("<input type=\"hidden\" name=\"payment[token]\" />").val(token));
            $("[data-stripe=number]").remove();
            $("[data-stripe=cvc]").remove();
            $("[data-stripe=exp-year]").remove();
            $("[data-stripe=exp-month]").remove();
            $("[data-stripe=label]").remove();
            $form.get(0).submit();
        }
        return false;
    };

        show_error = (message) => {
            if($("#flash-messages").length < 1){
                $('#main').prepend("<div id='flash-messages'></div>")
            }

            $("#flash-messages").html(`<div class="alert alert-warning alert-dismissible" role="alert"><button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>${message}</div>`);
            $('.alert').delay(5000).fadeOut(3000);

            return false;
        };
});
