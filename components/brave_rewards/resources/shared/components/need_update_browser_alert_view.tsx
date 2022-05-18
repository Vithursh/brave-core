/* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this file,
* You can obtain one at http://mozilla.org/MPL/2.0/. */

import * as React from 'react'

import { LocaleContext } from '../lib/locale_context'

import { AlertCircleIcon } from 'brave-ui/components/icons'

interface Props {
  drawIcon: boolean
}

function DrawIcon () {
  return (
    <div className='need-update-browser-icon'>
      <AlertCircleIcon />
    </div>
  )
}

export function NeedUpdateBrowserAlertView (props: Props) {
  const { getString } = React.useContext(LocaleContext)

  return (
    <div className='need-update-browser-view'>
      { props.drawIcon ? DrawIcon() : null }
      <div>
        <div className='need-update-browser-header'>
          {getString('browserCannotReceiveBravePrivateAds')}
        </div>
        <div className='need-update-browser-body'>
          {getString('browserNeedsUpdatedToSeeAds')}
        </div>
      </div>
    </div>
  )
}
