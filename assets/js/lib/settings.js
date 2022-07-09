import { load, store } from './storage';

const SETTINGS_KEY = "settings";

export const EDITOR_FONT_SIZE = {
  normal: 14,
  large: 16,
};

export const EDITOR_THEME = {
  default: "default",
  highContrast: "highContrast",
};

const DEFAULT_SETTINGS = {
  editor_auto_completion: true,
  editor_auto_signature: true,
  editor_font_size: EDITOR_FONT_SIZE.normal,
  editor_theme: EDITOR_THEME.default,
  editor_markdown_word_wrap: true,
};

class SettingsStore {
  constructor() {
    this._settings = DEFAULT_SETTINGS;

    this._loadSettings();
  }

  get() {
    return this._settings;
  }

  _loadSettings() {
    const settings = load(SETTINGS_KEY);

    if (settings) {
      this._settings = { ...this._settings, ...settings };
    }
  }
}

export const settingsStore = new SettingsStore();

