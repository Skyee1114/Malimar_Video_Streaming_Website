@chosenify = (entry) ->
  entry.chosen
    allow_single_deselect: true
    width: '240px'

$ -> 
  chosenify $(".chosen")

  $("form.formtastic .inputs .has_many").click ->
    $(".chosen").chosen
      allow_single_deselect: true
