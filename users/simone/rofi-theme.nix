{ background ? "#0f0f0fff"
, background-alt ? "#181818ff"
, foreground ? "#d8d8d8ff"
, selected ? "#f4bf75ff"
, active ? "#75b5aaff"
, urgent ? "#ac4242ff"
}: ''
  * {
    background:     ${background};
    background-alt: ${background-alt};
    foreground:     ${foreground};
    selected:       ${selected};
    active:         ${active};
    urgent:         ${urgent};

    border-colour:               var(selected);
    handle-colour:               var(foreground);
    background-colour:           var(background);
    foreground-colour:           var(foreground);
    alternate-background:        var(background-alt);
    normal-background:           var(background);
    normal-foreground:           var(foreground);
    urgent-background:           var(urgent);
    urgent-foreground:           var(background);
    active-background:           var(active);
    active-foreground:           var(background);
    selected-normal-background:  var(selected);
    selected-normal-foreground:  var(background);
    selected-urgent-background:  var(active);
    selected-urgent-foreground:  var(background);
    selected-active-background:  var(urgent);
    selected-active-foreground:  var(background);
    alternate-normal-background: var(background);
    alternate-normal-foreground: var(foreground);
    alternate-urgent-background: var(urgent);
    alternate-urgent-foreground: var(background);
    alternate-active-background: var(active);
    alternate-active-foreground: var(background);
  }

  /*****----- Main Window -----*****/
  window {
    /* properties for window widget */
    transparency:                "real";
    fullscreen:                  false;
    width:                       100%;

    children:                    [ "vertbox" ];

    /* properties for all widgets */
    enabled:                     true;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                @border-colour;
    cursor:                      "default";
    background-color:            @background-colour;
  }

  /*****----- Vertical Box -----*****/
  vertbox {
    spacing:                     0px;
    background-color:            @background-colour;
    text-color:                  @foreground-colour;
    orientation:                 vertical;
    children:                    [ "horibox", "message" ];
  }

  /*****----- Horizontal Box -----*****/
  horibox {
    spacing:                     0px;
    background-color:            @background-colour;
    text-color:                  @foreground-colour;
    orientation:                 horizontal;
    children:                    [ "prompt", "textbox-prompt-colon", "entry", "listview" ];
  }

  /*****----- Main Box -----*****/
  mainbox {
    enabled:                     true;
    spacing:                     20px;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px 0px 0px 0px;
    border-color:                @border-colour;
    background-color:            transparent;
    children:                    [ "inputbar", "message", "listview", "mode-switcher" ];
  }

  /*****----- Inputbar -----*****/
  inputbar {
    enabled:                     true;
    spacing:                     10px;
    margin:                      0px;
    padding:                     3px 8px;
    border:                      0px solid;
    border-radius:               4px;
    border-color:                @border-colour;
    background-color:            @alternate-background;
    text-color:                  @foreground-colour;
    children:                    [ "prompt", "entry" ];
  }
  prompt {
    enabled:                     true;
    padding:                     3px 8px;
    background-color:            inherit;
    text-color:                  inherit;
  }
  textbox-prompt-colon {
    enabled:                     true;
    padding:                     3px 0px 3px 0px;
    expand:                      false;
    str:                         "::";
    background-color:            inherit;
    text-color:                  inherit;
  }
  entry {
    enabled:                     true;
    padding:                     3px 8px;
    expand:                      false;
    width:                       20em;
    background-color:            inherit;
    text-color:                  inherit;
    cursor:                      text;
    placeholder:                 "Search...";
    placeholder-color:           inherit;
  }
  num-filtered-rows {
    enabled:                     true;
    expand:                      false;
    background-color:            inherit;
    text-color:                  inherit;
  }
  textbox-num-sep {
    enabled:                     true;
    expand:                      false;
    str:                         "/";
    background-color:            inherit;
    text-color:                  inherit;
  }
  num-rows {
    enabled:                     true;
    expand:                      false;
    background-color:            inherit;
    text-color:                  inherit;
  }
  case-indicator {
    enabled:                     true;
    background-color:            inherit;
    text-color:                  inherit;
  }

  /*****----- Listview -----*****/
  listview {
    enabled:                     true;
    columns:                     1;
    lines:                       100;
    cycle:                       true;
    dynamic:                     true;
    scrollbar:                   false;
    layout:                      horizontal;
    reverse:                     false;
    fixed-height:                true;
    fixed-columns:               true;

    spacing:                     10px;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                @border-colour;
    background-color:            transparent;
    text-color:                  @foreground-colour;
    cursor:                      "default";
  }
  scrollbar {
    handle-width:                5px ;
    handle-color:                @handle-colour;
    border-radius:               8px;
    background-color:            @alternate-background;
  }

  /*****----- Elements -----*****/
  element {
    enabled:                     true;
    spacing:                     8px;
    margin:                      0px;
    padding:                     3px 8px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                @border-colour;
    background-color:            transparent;
    text-color:                  @foreground-colour;
    cursor:                      pointer;
  }
  element normal.normal {
    background-color:            var(normal-background);
    text-color:                  var(normal-foreground);
  }
  element normal.urgent {
    background-color:            var(urgent-background);
    text-color:                  var(urgent-foreground);
  }
  element normal.active {
    background-color:            var(active-background);
    text-color:                  var(active-foreground);
  }
  element selected.normal {
    background-color:            var(selected-normal-background);
    text-color:                  var(selected-normal-foreground);
  }
  element selected.urgent {
    background-color:            var(selected-urgent-background);
    text-color:                  var(selected-urgent-foreground);
  }
  element selected.active {
    background-color:            var(selected-active-background);
    text-color:                  var(selected-active-foreground);
  }
  element alternate.normal {
    background-color:            var(alternate-normal-background);
    text-color:                  var(alternate-normal-foreground);
  }
  element alternate.urgent {
    background-color:            var(alternate-urgent-background);
    text-color:                  var(alternate-urgent-foreground);
  }
  element alternate.active {
    background-color:            var(alternate-active-background);
    text-color:                  var(alternate-active-foreground);
  }
  element-icon {
    background-color:            transparent;
    text-color:                  inherit;
    size:                        24px;
    cursor:                      inherit;
  }
  element-text {
    background-color:            transparent;
    text-color:                  inherit;
    highlight:                   inherit;
    cursor:                      inherit;
    vertical-align:              0.5;
    horizontal-align:            0.0;
  }

  /*****----- Mode Switcher -----*****/
  mode-switcher {
    enabled:                     true;
    spacing:                     10px;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               4px;
    border-color:                @border-colour;
    background-color:            @alternate-background;
    text-color:                  @foreground-colour;
  }
  button {
    padding:                     3px 8px;
    border:                      0px solid;
    border-radius:               4px;
    border-color:                @border-colour;
    background-color:            transparent;
    text-color:                  inherit;
    cursor:                      pointer;
  }
  button selected {
    background-color:            var(normal-foreground);
    text-color:                  var(normal-background);
  }

  /*****----- Message -----*****/
  message {
    enabled:                     true;
    margin:                      0px;
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px 0px 0px 0px;
    border-color:                @border-colour;
    background-color:            transparent;
    text-color:                  @foreground-colour;
  }
  textbox {
    padding:                     3px 8px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                @border-colour;
    background-color:            @background-colour;
    text-color:                  @foreground-colour;
    vertical-align:              0.5;
    horizontal-align:            0.0;
    highlight:                   none;
    placeholder-color:           @foreground-colour;
    blink:                       true;
    markup:                      true;
  }
  error-message {
    padding:                     0px;
    border:                      0px solid;
    border-radius:               0px;
    border-color:                @border-colour;
    background-color:            @background-colour;
    text-color:                  @foreground-colour;
  }
''
