import * as React from 'react'
import styled, { css } from 'styled-components'

import getPanelBrowserAPI from '../../api/panel_browser_api'

interface Props {
  isExpanded: boolean
  children?: React.ReactChildren | React.ReactElement
}

interface ScrollBoxProps {
  scrollHeight?: number | null
}

const ScrollBox = styled.div<ScrollBoxProps>`
  --height: auto;

  overflow: auto;
  max-height: var(--height);

  ${p => p.scrollHeight && css`
    --height: ${p.scrollHeight}px;
  `}

  &::-webkit-scrollbar {
    width: 8px;
  }

  &::-webkit-scrollbar-track {
    background: ${p => p.theme.color.subtleBackground};
  }

  &::-webkit-scrollbar-thumb {
    background: ${p => p.theme.color.subtle};
  }
`

function Scroller (props: Props) {
  const ref = React.useRef<HTMLDivElement>(null)
  const [rect, setRect] = React.useState<DOMRectReadOnly | undefined>(undefined)

  let scrollHeight: number|null = null

  if (rect && rect.bottom >= window.screen.height) {
    const diff = rect.bottom - window.screen.height
    if (ref.current) {
      scrollHeight = ref.current.scrollHeight - diff
    }
  }

  const getPanelRect = async () => {
    const { rect } = await getPanelBrowserAPI().panelHandler.getRect()
    // We read width/height from window object because
    // the browser will reflow and always return
    // accurate values
    const rectReadOnly = new DOMRectReadOnly(
      rect.x, rect.y,
      window.innerWidth, window.innerHeight)
    setRect(rectReadOnly)
  }

  React.useEffect(() => {
    if (props.isExpanded) {
      getPanelRect()
    }
  }, [props.isExpanded])

  return (
    <ScrollBox ref={ref} scrollHeight={scrollHeight}>
      {props.children}
    </ScrollBox>
  )
}

export default Scroller
