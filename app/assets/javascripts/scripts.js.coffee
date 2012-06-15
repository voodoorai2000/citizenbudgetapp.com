$ ->
  $('.dropdown-toggle').dropdown()
  $('.popover-toggle').popover()

  if $('nav').length
    $window = $ window
    $nav    = $ 'nav'
    offset  = $nav.length && $nav.offset().top

    # Set active menu item.
    $('body').scrollspy
      target: 'nav'
      offset: 50

    # Smooth scrolling.
    $nav.localScroll
      axis: 'y'
      duration: 500
      easing: 'easeInOutExpo'
      #margin: true
      offset: -50
      hash: true

    # Fixed menu.
    processScroll = ->
      $nav.toggleClass 'nav-fixed', $window.scrollTop() >= offset
    $window.on 'scroll', processScroll
    processScroll()
