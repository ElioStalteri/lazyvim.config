local Highlite = require("highlite") --- @type Highlite

local sublimeColors = {
  green = "#a6e228",
  blue = "#56d8ef",
  white = "#f8f8f2",
  red = "#c92468",
  yallow = "#e7db74",
  purple = "#7b76ff",
  orange = "#e76d22",
  comment = "#74705d",
  background = "#282923",
  background1 = "#232418",
  background2 = "#181913",
}

-- the idea is to edit the palette below with the colors above and then use the following library to use the theme
--  https://github.com/Iron-E/nvim-highlite

--- @type highlite.color.palette.get
local function get()
  local terminal_palette = {
    [1] = "#181819",
    [2] = sublimeColors.red,
    [3] = sublimeColors.green,
    [4] = sublimeColors.yallow,
    [5] = sublimeColors.blue,
    [6] = sublimeColors.purple,
    [7] = sublimeColors.orange,
    [8] = sublimeColors.white,
    [9] = "#7F8490",
    [10] = sublimeColors.red,
    [11] = sublimeColors.green,
    [12] = sublimeColors.yallow,
    [13] = sublimeColors.blue,
    [14] = sublimeColors.purple,
    [15] = sublimeColors.orange,
    [16] = sublimeColors.white,
  }

  local palette = {
    annotation = sublimeColors.blue,
    attribute = sublimeColors.blue,
    bg = sublimeColors.background,
    bg_contrast_high = "#414550",
    bg_contrast_low = "#33353F",
    boolean = sublimeColors.purple,
    buffer_active = sublimeColors.white,
    buffer_alternate = "#A7DF78",
    buffer_current = "#3B3E48",
    character = sublimeColors.yallow,
    character_special = sublimeColors.purple,
    class = sublimeColors.blue,
    comment = "#7F8490",
    comment_documentation = "#7F8490",
    conditional = sublimeColors.red,
    constant = sublimeColors.white,
    constant_builtin = sublimeColors.purple,
    constructor = sublimeColors.green,
    decorator = sublimeColors.green,
    define = sublimeColors.red,
    diff_add = sublimeColors.green,
    diff_change = sublimeColors.blue,
    diff_delete = sublimeColors.red,
    enum = sublimeColors.blue,
    error = sublimeColors.red,
    event = sublimeColors.red,
    field = sublimeColors.orange,
    field_enum = sublimeColors.orange,
    float = sublimeColors.purple,
    fold = "#33353F",
    func = sublimeColors.green,
    func_builtin = sublimeColors.green,
    hint = sublimeColors.green,
    identifier = sublimeColors.orange,
    include = sublimeColors.red,
    info = sublimeColors.blue,
    interface = sublimeColors.blue,
    keyword = sublimeColors.red,
    keyword_coroutine = sublimeColors.red,
    keyword_function = sublimeColors.blue,
    keyword_operator = sublimeColors.red,
    keyword_return = sublimeColors.red,
    label = sublimeColors.red,
    loop = sublimeColors.red,
    macro = sublimeColors.purple,
    message = sublimeColors.white,
    method = sublimeColors.green,
    namespace = sublimeColors.yallow,
    number = sublimeColors.purple,
    ok = "#90EE90",
    operator = sublimeColors.red,
    parameter = sublimeColors.orange,
    preproc = sublimeColors.red,
    preproc_conditional = sublimeColors.red,
    property = sublimeColors.white,
    punctuation = sublimeColors.white,
    punctuation_bracket = "#7F8490",
    punctuation_delimiter = "#7F8490",
    punctuation_special = sublimeColors.yallow,
    search = "#A7DF78",
    select = "#3B3E48",
    special = sublimeColors.purple,
    statement = sublimeColors.red,
    storage = sublimeColors.red,
    string = sublimeColors.yallow,
    string_escape = sublimeColors.green,
    string_regex = sublimeColors.green,
    string_special = sublimeColors.purple,
    structure = sublimeColors.blue,
    syntax_error = "#642531",
    tag = sublimeColors.red,
    tag_attribute = sublimeColors.green,
    tag_delimiter = sublimeColors.red,
    text = sublimeColors.white,
    text_contrast_bg_high = sublimeColors.white,
    text_contrast_bg_low = "#7F8490",
    text_environment = sublimeColors.purple,
    text_environment_name = sublimeColors.blue,
    text_literal = sublimeColors.yallow,
    text_math = sublimeColors.yallow,
    text_reference = sublimeColors.orange,
    throw = sublimeColors.red,
    todo = sublimeColors.blue,
    type = sublimeColors.blue,
    type_builtin = sublimeColors.blue,
    type_parameter = sublimeColors.blue,
    uri = sublimeColors.blue,
    variable = sublimeColors.white,
    variable_builtin = sublimeColors.purple,
    warning = sublimeColors.yallow,
  }

  return palette, terminal_palette
end

local palette, terminal_palette = get()

local groups = Highlite.groups("default", palette)
Highlite.generate("sublime", groups, terminal_palette)
