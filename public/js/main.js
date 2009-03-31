$( function() {
    $("#draggable").draggable();

    $("#droppable").droppable({
        greedy: true,
        drop: function(event, ui) {
            $(this).addClass('ui-state-highlight').find('p').html('Plunk!');
        }
    });

    $("#main").droppable({
        drop: function(event, ui) {
            $('#droppable').removeClass('ui-state-highlight');
            $('#droppable > p').html('');
        }
    });
} );