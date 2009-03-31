$( function() {
    $("#draggable").draggable();

    $("#droppable").droppable({
        drop: function(event, ui) {
            $(this).addClass('ui-state-highlight').find('p').html('Plunk!');
        }
    });
} );