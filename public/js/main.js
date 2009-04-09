function cl(arg) {
  if(window.console) console.log(arg);
}

$(function() {
  // there's the items and the cart
  var $items = $('.items'), $cart = $('#cart');
  var $info = $('#info .infos');
  var $trash = $('#trash');

  function execute_drop(url, payload){
    $.post(url, payload, function(json){
      var p = $('<p>' + json['result'] + '</p>');
      $info.prepend(p)
      p.hide();
      p.fadeIn(1000, function(){  });
    }, 'json');
  }

  // let the items be draggable
  function drag_able(obj){
    obj.draggable({
      cancel: 'a.ui-icon',// clicking an icon won't initiate dragging
      revert: 'invalid', // when not dropped, the item will revert back to its initial position
      containment: 'document',
      helper: 'clone',
      cursor: 'move'
    });
  }

  // let the cart be droppable, accepting the items
  function drop_in_able(obj){
    obj.droppable({
      accept: '#items > li.item',
      activeClass: 'ui-state-highlight',
      drop: function(ev, ui) { drop_in($(ui.draggable[0])); }
    });
  }

  function drop_in(item){
    add_to_cart(item);
    var payload = payload_for(item);

    execute_drop('/dropped_in.json', payload);
  }

  // let the items be droppable as well, accepting items from the cart
  function drop_out_able(obj){
    obj.droppable({
      accept: '#cart li.item',
      activeClass: 'custom-state-active',
      drop: function(ev, ui){ drop_out($(ui.draggable[0])) }
    });
  }

  function drop_out(item){
    remove_from_cart(item);
    var payload = payload_for(item);

    execute_drop('/dropped_out.json', payload);
  }

  function payload_for(item){
    var item_id = $('.item-id', item)[0].innerHTML;
    return({item_id: item_id});
  }

  // clone the item and add the clone to the cart
  // then change the icon
  var remove_icon = '<a href="remove" title="Remove from cart" class="ui-icon ui-icon-trash">Remove from cart</a>';
  function add_to_cart(item){
    var clone = item.clone();
    drag_able(clone);

    clone.appendTo($('ul', $cart)).hide().fadeIn(500, function(){
      clone.find('a.ui-icon-cart').remove();
      clone.append(remove_icon);
      add_click_events(clone);
    });
  }

  // remove the item from the cart totally.
  var cart_icon = '<a href="add" title="Add to cart" class="ui-icon ui-icon-cart">Add to cart</a>';
  function remove_from_cart(item){
    item.fadeOut(500, function(){
      item.remove();
      // $item.find('a.ui-icon-trash').remove();
      // $item.append(cart_icon);
    });
  }

  // resolve the icons behavior with event delegation
  function add_click_events(obj){
    obj.click(function(ev) {
      var $item = $(this);
      var $target = $(ev.target);

      if ($target.is('a.ui-icon-cart')) {
        drop_in($item);
      } else if ($target.is('a.ui-icon-trash')) {
        drop_out($item);
      }

      return false;
    });
  }

  drag_able($('li', $items));
  drop_in_able($cart);
  drop_out_able($('#items'));
  drop_out_able($trash);
  add_click_events($('ul.items > li'));
});
