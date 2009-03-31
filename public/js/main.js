$( function() {
  $(".draggable").draggable();

  $("#droppable").droppable({
    greedy: true,
    drop: function(event, ui) {
      var target = $(this);
      var item = ui.draggable[0];

      target.addClass('ui-state-highlight');
      $(item).addClass('in-cart');

      $.post(
        '/dropped_in.json',
        { item_id: item.id },
        function( json ) {
        target.find('p').html( 'Server says: ' + json['result']);
      },
      'json');
    }
  });

  $("#main").droppable({
    drop: function(event, ui) {
      var item = ui.draggable[0];

      $('#droppable').removeClass('ui-state-highlight');
      $(item).removeClass('in-cart');

      $.post(
        '/dropped_out.json',
        { item_id: item.id },
        function( json ) {
        $('#droppable > p').html( 'Server says: ' + json['result']);
      },
      'json');
    }
  });
} );
