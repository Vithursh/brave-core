/* Copyright (c) 2022 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "brave/browser/ui/views/omnibox/brave_omnibox_result_view.h"

#include "brave/components/omnibox/browser/promotion_utils.h"
#include "components/omnibox/browser/autocomplete_controller.h"
#include "components/omnibox/browser/autocomplete_match.h"
#include "components/omnibox/browser/autocomplete_result.h"
#include "components/omnibox/browser/omnibox_edit_model.h"
#include "ui/base/metadata/metadata_impl_macros.h"

BraveOmniboxResultView::BraveOmniboxResultView(
    OmniboxPopupContentsView* popup_contents_view,
    OmniboxEditModel* model,
    size_t model_index)
    : OmniboxResultView(popup_contents_view, model, model_index),
      edit_model_(model) {}

BraveOmniboxResultView::~BraveOmniboxResultView() = default;

void BraveOmniboxResultView::SetMatch(const AutocompleteMatch& match) {
  OmniboxResultView::SetMatch(match);
  const auto input = edit_model_->autocomplete_controller()->input();
  is_brave_search_promotion_ = IsBraveSearchPromotionMatch(match, input.text());
}

BEGIN_METADATA(BraveOmniboxResultView, OmniboxResultView)
END_METADATA
