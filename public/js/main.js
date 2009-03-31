$( function() {
    $("#draggable").draggable();

    $("#droppable").droppable({
        greedy: true,
        drop: function(event, ui) {
            var target = $(this);
            target.addClass('ui-state-highlight');

            $.post(
                '/dropped_in.json',
                { component_id: 'foo' },
                function( json ) {
                    target.find('p').html( 'Server says: ' + json['result']);
                },
                'json');
        }
    });

    $("#main").droppable({
        drop: function(event, ui) {
            $('#droppable').removeClass('ui-state-highlight');
            $.post(
                '/dropped_out.json',
                { component_id: 'foo' },
                function( json ) {
                    $('#droppable > p').html( 'Server says: ' + json['result']);
                },
                'json');
        }
    });
} );