/* Copyright (c) 2020 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at https://mozilla.org/MPL/2.0/. */

#include "brave/components/brave_ads/core/ad_info.h"

#include <tuple>

namespace brave_ads {

AdInfo::AdInfo() = default;

AdInfo::AdInfo(const AdInfo& other) = default;

AdInfo& AdInfo::operator=(const AdInfo& other) = default;

AdInfo::AdInfo(AdInfo&& other) noexcept = default;

AdInfo& AdInfo::operator=(AdInfo&& other) noexcept = default;

AdInfo::~AdInfo() = default;

bool AdInfo::operator==(const AdInfo& other) const {
  const auto tie = [](const AdInfo& ad) {
    return std::tie(ad.type, ad.placement_id, ad.creative_instance_id,
                    ad.creative_set_id, ad.campaign_id, ad.advertiser_id,
                    ad.segment, ad.target_url);
  };

  return tie(*this) == tie(other);
}

bool AdInfo::operator!=(const AdInfo& other) const {
  return !(*this == other);
}

bool AdInfo::IsValid() const {
  return type != AdType::kUndefined && !placement_id.empty() &&
         !creative_instance_id.empty() && !creative_set_id.empty() &&
         !campaign_id.empty() && !advertiser_id.empty() && !segment.empty() &&
         target_url.is_valid();
}

}  // namespace brave_ads
