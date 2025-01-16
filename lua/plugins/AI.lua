return {
  -- {
  --   "Exafunction/codeium.vim",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "hrsh7th/nvim-cmp",
  --   },
  --   event = "BufEnter",
  --   -- config = function()
  --   --   vim.g.codeium_no_map_tab = true
  --   -- end,
  --   keys = {
  --     -- { "<leader>ac", "<cmd>Codeium Chat<cr>", desc = "open chat" },
  --     { "<leader>aa", "<cmd>Codeium Auth<cr>", desc = "Codeium Auth" },
  --     { "<leader>at", "<cmd>Codeium Toggle<cr>", desc = "Codeium Toggle" },
  --     { mode = { "i" }, "<C-c>", "<Cmd>call codeium#Clear()<CR>", desc = "Clear suggestion" },
  --     -- WARN: <C-y> does'n work :(
  --     -- { mode = { "i" }, "<C-y>", "<Cmd>call codeium#Accept()<CR>", desc = "Accept suggestion" },
  --     { mode = { "i" }, "<C-n>", "<Cmd>call codeium#CycleCompletions(1)<CR>", desc = "Next suggestion" },
  --     { mode = { "i" }, "<C-p>", "<Cmd>call codeium#CycleCompletions(-1)<CR>", desc = "Previous suggestion" },
  --   },
  -- },

  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    keys = {
      -- PrtChatNew <target>	Open a new chat
      -- PrtChatToggle <target>	Toggle chat (open last chat or new one)
      -- PrtChatPaste <target>	Paste visual selection into the latest chat
      -- PrtInfo	Print plugin config
      -- PrtContext <target>	Edits the local context file
      -- PrtChatFinder	Fuzzy search chat files using fzf
      -- PrtChatDelete	Delete the current chat file
      -- PrtChatRespond	Trigger chat respond (in chat file)
      -- PrtStop	Interrupt ongoing respond
      -- PrtProvider <provider>	Switch the provider (empty arg triggers fzf)
      -- PrtModel <model>	Switch the model (empty arg triggers fzf)
      -- PrtStatus	Prints current provider and model selection
      -- Interactive
      -- PrtRewrite	Rewrites the visual selection based on a provided prompt
      -- PrtEdit	Like PrtRewrite but you can change the last prompt
      -- PrtAppend	Append text to the visual selection based on a provided prompt
      -- PrtPrepend	Prepend text to the visual selection based on a provided prompt
      -- PrtNew	Prompt the model to respond in a new window
      -- PrtEnew	Prompt the model to respond in a new buffer
      -- PrtVnew	Prompt the model to respond in a vsplit
      -- PrtTabnew	Prompt the model to respond in a new tab
      -- PrtRetry	Repeats the last rewrite/append/prepend
      -- Example Hooks
      -- PrtImplement	Takes the visual selection as prompt to generate code
      -- PrtAsk	Ask the model a question
      { "<leader>ae", "<cmd>PrtRewrite<cr>", mode = { "v" }, desc = "edit eselction" },
      { "<leader>af", "<cmd>PrtChatFinder<cr>", desc = "chat finder" },
      { "<leader>ai", "<cmd>PrtImplement<cr>", mode = { "v" }, desc = "implement from selection" },
      { "<leader>ak", "<cmd>PrtAsk<cr>", desc = "ask" },
      { "<leader>ad", "<cmd>PrtChatDelete<cr>", desc = "delete chat" },
      { "<leader>as", "<cmd>PrtStop<cr>", desc = "stop respond" },
      { "<leader>an", "<cmd>PrtChatNew<cr>", desc = "new chat" },
      { "<leader>ap", "<cmd>PrtChatPaste<cr>", desc = "paste in chat" },
      { "<leader>ac", "<cmd>PrtChatToggle<cr>", desc = "toggle chat" },
      { "<leader>ar", "<cmd>PrtChatRespond<cr>", desc = "chat respond" },
    },
    config = function()
      require("parrot").setup({
        -- chat_shortcut_respond = { modes = { "n" }, shortcut = "<leader>ar" },
        -- chat_shortcut_delete = { modes = { "n" }, shortcut = "<leader>ad" },
        -- chat_shortcut_stop = { modes = { "n" }, shortcut = "<leader>as" },
        -- chat_shortcut_new = { modes = { "n" }, shortcut = "<leader>an" },
        -- Providers must be explicitly added to make them available.
        providers = {
          -- anthropic = {
          --   api_key = os.getenv("ANTHROPIC_API_KEY"),
          -- },
          gemini = {
            api_key = os.getenv("AI_API_KEY"),
          },
          -- groq = {
          --   api_key = os.getenv("GROQ_API_KEY"),
          -- },
          -- mistral = {
          --   api_key = os.getenv("MISTRAL_API_KEY"),
          -- },
          -- pplx = {
          --   api_key = os.getenv("PERPLEXITY_API_KEY"),
          -- },
          -- provide an empty list to make provider available (no API key required)
          -- ollama = {},
          -- openai = {
          --   api_key = os.getenv("OPENAI_API_KEY"),
          -- },
          -- github = {
          --   api_key = os.getenv("GITHUB_TOKEN"),
          -- },
          -- nvidia = {
          --   api_key = os.getenv("NVIDIA_API_KEY"),
          -- },
          -- xai = {
          --   api_key = os.getenv("XAI_API_KEY"),
          -- },
        },
      })
    end,
  },
}
