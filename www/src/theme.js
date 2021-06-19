import { css } from 'styled-components'

const boxStyle = css`
  outline: none;
`;

export const DEFAULT_COLOR_THEME = {
  brand: '#3B1D98',
  action: '#007a5a',
  sidebar: '#13141a',
  sidebarHover: '#000000',
  sidebarActive: '#000000',
  focus: '#3B1D98',
  progress: '#007bff',
  tagMedium: '#3B1D98',
  tagLight: '#624aad',
  backgroundColor: '#2b2d33',
  orange: '#d7722c',
  error: '#CC4400',
  presence: '#39E500',
  success: 'action',
  link: '#3366BB',
  notif: 'error',
  good: '#00ac46',
  low: '#fdc500',
  medium: '#fd8c00',
  high: '#dc0000',
  critical: '#780000'
}

export const DEFAULT_THEME = {
  anchor: {
    color: {light: 'link', dark: 'white'},
    hover: {
      textDecoration: 'none',
      extend: 'font-weight: 600'
    },
    fontWeight: 400,
  },
  button: {
    padding: {
      horizontal: '6px',
      vertical: '2px'
    }
  },
  box: {
    extend: boxStyle
  },
  tab: {
    active: {color: 'focus'},
    border: {active: {color: 'focus'}, hover: {color: 'focus'}},
  },
  textArea: {
    extend: {
      fontWeight: 400
    }
  },
  textInput: {
    extend: {
      fontWeight: 400
    }
  },
  calendar: {
    day: {
      extend: {
        borderRadius: '5px',
        fontWeight: 'normal'
      }
    }
  },
  textField: {
    extend: {
      fontWeight: 400
    }
  },
  select: {
    options: {
      text: {size: 'small'}
    }
  },
  drop: {border: {radius: '4px'}},
  global: {
    colors: DEFAULT_COLOR_THEME,
    focus: {shadow: { size: '1px' } },
    control: {border: {radius: '2px'}},
    drop: {
      border: {
        radius: '4px'
      }
    },
    box: {
      extend: boxStyle
    },
    font: {
      family: 'Roboto',
      size: '14px',
      height: '20px',
    },
  },
}