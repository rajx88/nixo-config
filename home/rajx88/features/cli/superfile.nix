{pkgs, ...}: {
  programs.superfile = {
    enable = true;

    hotkeys = {
      # Basic actions
      confirm = ["enter"];
      quit = ["ctrl+c"];
      cd_quit = ["Q"];

      # Navigation
      list_up = ["k"];
      list_down = ["j"];
      page_up = ["pgup"];
      page_down = ["pgdown"];

      # File panel controls
      create_new_file_panel = ["n"];
      close_file_panel = ["q"];
      next_file_panel = ["tab"];
      previous_file_panel = ["shift+tab"];
      split_file_panel = ["N"];
      toggle_file_preview_panel = ["f"];
      open_sort_options_menu = ["o"];
      toggle_reverse_sort = ["R"];

      # Focus manipulation
      focus_on_process_bar = ["ctrl+p"];
      focus_on_sidebar = ["ctrl+s"];
      focus_on_metadata = ["ctrl+d"];

      # File/dir creation and renaming
      file_panel_item_create = ["a"];
      file_panel_item_rename = ["r"];

      # Main file operations
      copy_items = ["y"];
      cut_items = ["x"];
      paste_items = ["p"];
      delete_items = ["d"];
      permanently_delete_items = ["D"];

      # Archive manipulation
      extract_file = ["ctrl+e"];
      compress_file = ["ctrl+a"];

      # Editor actions
      open_file_with_editor = ["e"];
      open_current_directory_with_editor = ["E"];

      # Other actions
      pinned_directory = ["P"];
      toggle_dot_file = ["."];
      change_panel_mode = ["m"];
      open_help_menu = ["?"];
      open_spf_prompt = [">"];
      open_command_line = [":"];
      open_zoxide = ["z"];
      copy_path = ["Y"];
      copy_present_working_directory = ["c"];
      toggle_footer = ["ctrl+f"];

      # Typing
      confirm_typing = ["enter"];
      cancel_typing = ["esc"];

      # Mode-specific
      parent_directory = ["-"];
      search_bar = ["/"];
      file_panel_select_mode_items_select_down = ["J"];
      file_panel_select_mode_items_select_up = ["K"];
      file_panel_select_all_items = ["A"];
    };
  };
}
