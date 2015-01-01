$(document).ready(function() {
  var location_pathname = location.pathname;

  if (location_pathname != '/') {
    $(".top-nav a[href='" + location.pathname + "']").addClass('current');
  }

  var $loading = $("#loading").hide();

  $(document)
    .ajaxStart(function() {
      $loading.show();
    })
    .ajaxStop(function() {
      $loading.hide();
    });

  $(".result-types-form input[type=radio]").change(function(value) {
    var $resultTypesForm = $(".result-types-form");

    var organizationName = $resultTypesForm.data('organization-name');
    var repoName = $resultTypesForm.data('repo-name');
    var name = $resultTypesForm.data('name')

    $.ajax({
      url: "/" + organizationName + "/" + repoName + "/" + name,
      type: 'GET',
      data: { result_type: $(this).val() },
      dataType: 'script',
      beforeSend: function() {
        $("#chart-container").empty();
      }
    });
  })
})
