$(function() {
  // there's the items and the cart
  var $items = $('#items'), $cart = $('#cart');

  // let the items items be draggable
  $('li',$items).draggable({
    cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
    revert: 'invalid', // when not dropped, the item will revert back to its initial position
    containment: $('#demo-frame').length ? '#demo-frame' : 'document', // stick to demo-frame if present
    helper: 'clone',
    cursor: 'move'
  });

  // let the cart be droppable, accepting the items items
  $cart.droppable({
    accept: '#items > li',
    activeClass: 'ui-state-highlight',
    drop: function(ev, ui) {
      deleteImage(ui.draggable);

      $.post(
        '/dropped_in.json',
        { item_id: ui.draggable[0].id },
        function( json ) {
        $('#cart > p').html( 'Server says: ' + json['result']);
      },
      'json');
    }
  });

  // let the items be droppable as well, accepting items from the cart
  $items.droppable({
    accept: '#cart li',
    activeClass: 'custom-state-active',
    drop: function(ev, ui) {
      recycleImage(ui.draggable);

      $.post(
        '/dropped_out.json',
        { item_id: ui.draggable[0].id },
        function( json ) {
        $('#cart > p').html( 'Server says: ' + json['result']);
      },
      'json');
    }
  });

  // image deletion function
  var recycle_icon = '<a href="link/to/recycle/script/when/we/have/js/off" title="Recycle this image" class="ui-icon ui-icon-refresh">Recycle image</a>';
  function deleteImage($item) {
    $item.fadeOut(function() {
      var $list = $('ul',$cart).length ? $('ul',$cart) : $('<ul class="items ui-helper-reset"/>').appendTo($cart);

      $item.find('a.ui-icon-cart').remove();
      $item.append(recycle_icon).appendTo($list).fadeIn(function() {
        $item.animate({ width: '48px' }).find('img').animate({ height: '36px' });
      });
    });
  }

  // image recycle function
  var cart_icon = '<a href="link/to/cart/script/when/we/have/js/off" title="Delete this image" class="ui-icon ui-icon-cart">Delete image</a>';
  function recycleImage($item) {
    $item.fadeOut(function() {
      $item.find('a.ui-icon-refresh').remove();
      $item.css('width','96px').append(cart_icon).find('img').css('height','72px').end().appendTo($items).fadeIn();
    });
  }

  // image preview function, demonstrating the ui.dialog used as a modal window
  function viewLargerImage($link) {
    var src = $link.attr('href');
    var title = $link.siblings('img').attr('alt');
    var $modal = $('img[src$="'+src+'"]');

    if ($modal.length) {
      $modal.dialog('open')
    } else {
      var img = $('<img alt="'+title+'" width="384" height="288" style="display:none;padding: 8px;" />')
        .attr('src',src).appendTo('body');
      setTimeout(function() {
        img.dialog({
            title: title,
            width: 400,
            modal: true
          });
      }, 1);
    }
  }

  // resolve the icons behavior with event delegation
  $('ul.items > li').click(function(ev) {
    var $item = $(this);
    var $target = $(ev.target);

    if ($target.is('a.ui-icon-cart')) {
      deleteImage($item);
    } else if ($target.is('a.ui-icon-zoomin')) {
      viewLargerImage($target);
    } else if ($target.is('a.ui-icon-refresh')) {
      recycleImage($item);
    }

    return false;
  });
});
