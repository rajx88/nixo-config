--       Uncomment any of the lines below to enable them.
-- require 'kickstart.plugins.autoformat',
-- require 'kickstart.plugins.debug',

-- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
--    up-to-date with whatever is in the kickstart repo.
--    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
--
--    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
-- { import = 'custom.plugins' },

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- import modules
require("rajkohlen.core")
require("rajkohlen.autocmd")
