function cl(arg) {
  if(window.console) console.log(arg);
}

$(function() {
  // there's the items and the cart
  var $items = $('.items'), $cart = $('#cart');

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
      accept: '#items > li',
      activeClass: 'ui-state-highlight',
      drop: function(ev, ui) { drop_in($(ui.draggable[0])); }
    });
  }

  function drop_in(item){
    cl({drop_in: item});

    add_to_cart(item);
    var payload = payload_for(item);

    $.post('/dropped_in.json', payload, function(json){
      $('#cart > p').html('Server says: ' + json['result']);
    }, 'json');
  }

  // let the items be droppable as well, accepting items from the cart
  function drop_out_able(obj){
    obj.droppable({
      accept: '#cart li',
      activeClass: 'custom-state-active',
      drop: function(ev, ui){ drop_out($(ui.draggable[0])) }
    });
  }

  function drop_out(item){
    cl({drop_out: item});

    remove_from_cart(item);
    var payload = payload_for(item);

    $.post('/dropped_out.json', payload, function(json){
      $('#cart > p').html('Server says: ' + json['result']);
    }, 'json');
  }

  function payload_for(item){
    var item_id = $('.item-id', item)[0].innerHTML;
    return({item_id: item_id});
  }

  // clone the item and add the clone to the cart
  // then change the icon
  var remove_icon = '<a href="remove" title="Remove from cart" class="ui-icon ui-icon-refresh">Remove from cart</a>';
  function add_to_cart(item){
    cl({add_to_cart: item});

    var clone = item.clone();
    drag_able(clone);

    clone.appendTo($('ul', $cart)).fadeIn(function(){
      clone.find('a.ui-icon-cart').remove();
      clone.append(remove_icon);
      add_click_events(clone);
    });
  }

  // remove the item from the cart totally.
  var cart_icon = '<a href="add" title="Add to cart" class="ui-icon ui-icon-cart">Add to cart</a>';
  function remove_from_cart(item){
    cl({remove_from_cart: item});
    item.fadeOut(function(){
      item.remove();
      // $item.find('a.ui-icon-refresh').remove();
      // $item.append(cart_icon);
    });
  }

  // resolve the icons behavior with event delegation
  function add_click_events(obj){
    obj.click(function(ev) {
      var $item = $(this);
      var $target = $(ev.target);

      if ($target.is('a.ui-icon-cart')) {
        add_to_cart($item);
      } else if ($target.is('a.ui-icon-refresh')) {
        remove_from_cart($item);
      }

      return false;
    });
  }

  drag_able($('li', $items));
  drop_in_able($cart);
  drop_out_able($items);
  add_click_events($('ul.items > li'));
});
