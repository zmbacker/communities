timer_popup = undefined
redactor = undefined
$ ->
  $("#sign-up .toggler label").on "click", ->
    $("#sign-up .toggler label").hasClass ""
    elem = $(this)
    $("#user_profession_and_degree").attr("data-validate", elem.hasClass "doctor" ? true : false)
    unless elem.hasClass("checked")
      $(".toggler label").toggleClass "checked"
      $(".doctor-only").toggleClass "hidden"
    jQuery.placeholder.shim() if jQuery.placeholder

  $(".b-auth .buttons a").on "click", ->
    elem = $(this)
    unless elem.hasClass("selected")
      $(".b-auth .buttons a").toggleClass "selected"
      $(".sign-tab").toggleClass "hidden"
    false

  $("a.sign-in").click()  if window.location.hash.indexOf("#sign-in") >= 0

  $(".b-popup-set-preview label").live "click", ->
    $(".b-popup-set-preview label").removeClass "checked"
    $(this).addClass "checked"

  $(".b-search-engine .btn.explore").live "click", ->
    $(".b-explore-popup").toggleClass "hidden"

  $(document).on
    mouseover: (e) ->
      timer_popup = window.setTimeout(->
        showUserPopup e
      , 500)
    click: (e) ->
      clearTimeout(timer_popup)
      showUserPopup e
    , ".popup-user-info"

  $(document).on
    mouseover: (e) ->
      timer_popup = window.setTimeout(->
        showItemPopup e
      , 500)
    click: (e) ->
      clearTimeout(timer_popup)
      showItemPopup e
    , ".popup-item-info"

  $(document).on "mouseleave", ".popup-item-info, .popup-user-info", ->
    obj_id = $(this).attr "id"
    unless $("." + obj_id + ":visible").length
      clearTimeout(timer_popup)

  $(document).on "mouseleave", ".popup-container", ->
    $(this).css("display","none")

  $(".light-button.set-preview").toggle (->
    obj_offset = $(this).offset()
    $(".b-popup-set-preview").css(
      top: (obj_offset.top + 55) + "px"
      left: (obj_offset.left - 135) + "px"
    ).fadeIn "fast"
  ), ->
    $(".b-popup-set-preview").fadeOut "fast"

  $(".b-settings-nav a").live "click", ->
    unless $(this).hasClass("selected")
      $(".b-settings-nav a").toggleClass "selected"
      $(".b-settings-tab").toggleClass "hidden"
    false

  $(document).on "click", ".main-content .navigation a", ->
    $(".main-content .navigation a").removeClass "selected"
    $(this).addClass "selected"
    false

  $(document).on "click", ".list-header .nav a", ->
    unless $(this).hasClass("selected")
      $(".list-header .nav a").removeClass "selected"
      $(this).addClass("selected")

  $(document).on "click", ".refresh-captcha", ->
    $(".simple_captcha").html('<div class="loading">Loading...</div>');

  $(document).on "click", ".popup-cleaner, .go-to-profile, .go-to-article, .main-content .navigation a", ->
    $(".popup-container").css("display","none");
    $(".l-settings-navigation").html("") if !$(this).hasClass "tab-settings"
