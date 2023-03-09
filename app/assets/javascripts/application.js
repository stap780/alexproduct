// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
//= require popper
//= require bootstrap
//= require cocoon
//= require_tree .


$(document).ready(function() {

  $(".alert").delay(4000).slideUp(200, function() {
    $(this).alert('close');
  });

  // SELECT ALL //
  $('#selectAll').click(function() {
    if (this.checked) {
      $(':checkbox').each(function() {
        this.checked = true;
      });
      //$('#deleteAll').show();
    } else {
      $(':checkbox').each(function() {
        this.checked = false;
      });
      //$('#deleteAll').hide();
    }
  });
  // SELECT ALL //
  // DELETE ALL //
  $('#deleteAll').click(function() {
    // event.preventDefault();
    var array = [];
    $('#items_table :checked').each(function() {
      array.push($(this).val());
    });
    $.ajax({
      type: "POST",
      url: $(this).attr('href') + '.json',
      data: {
        ids: array
      },
      beforeSend: function() {
        return confirm("Вы уверенны?");
      },
      success: function(data, textStatus, jqXHR) {
        if (data.status === 'ok') {
          //alert(data.message);
          location.reload();
        }
      },
      error: function(jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
      }
    })
  });
  // DELETE ALL //

  // $('#file').click(function() {
  //   $('.import_file_submit').css('display', 'block');
  // });

  // DELETE IMAGE //
  $(".delete-image").on("ajax:success", function(event, data, status, xhr) {
    var response = data.message;
    console.log('Response is => ' + response);
    if (data.message === 'destroyed') {
      // $(this).closest('tr').fadeOut();
      $(this).closest('.image-item').fadeOut();
    }
  });



  const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]')
  const popoverList = [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))

  $('.dropdown-menu1.checkboxes input').change(function() {
    $('.dropdown-menu1.checkboxes input').not(this).prop("checked", false);
  });
  $('.dropdown-menu2.checkboxes input').change(function() {
    $('.dropdown-menu2.checkboxes input').not(this).prop("checked", false);
  });

});
