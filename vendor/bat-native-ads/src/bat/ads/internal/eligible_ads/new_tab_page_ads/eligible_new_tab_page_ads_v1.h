/* Copyright (c) 2021 The Brave Authors. All rights reserved.
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef BRAVE_VENDOR_BAT_NATIVE_ADS_SRC_BAT_ADS_INTERNAL_ELIGIBLE_ADS_NEW_TAB_PAGE_ADS_ELIGIBLE_NEW_TAB_PAGE_ADS_V1_H_
#define BRAVE_VENDOR_BAT_NATIVE_ADS_SRC_BAT_ADS_INTERNAL_ELIGIBLE_ADS_NEW_TAB_PAGE_ADS_ELIGIBLE_NEW_TAB_PAGE_ADS_V1_H_

#include "bat/ads/internal/ad_events/ad_event_info_aliases.h"
#include "bat/ads/internal/ad_server/catalog/bundle/creative_new_tab_page_ad_info_aliases.h"
#include "bat/ads/internal/eligible_ads/eligible_ads_aliases.h"
#include "bat/ads/internal/eligible_ads/exclusion_rules/exclusion_rule_aliases.h"
#include "bat/ads/internal/eligible_ads/new_tab_page_ads/eligible_new_tab_page_ads_base.h"

namespace ads {

namespace targeting {
struct UserModelInfo;
namespace geographic {
class SubdivisionTargeting;
}  // namespace geographic
}  // namespace targeting

namespace resource {
class AntiTargeting;
}  // namespace resource

namespace new_tab_page_ads {

class EligibleAdsV1 final : public EligibleAdsBase {
 public:
  EligibleAdsV1(
      targeting::geographic::SubdivisionTargeting* subdivision_targeting,
      resource::AntiTargeting* anti_targeting);
  ~EligibleAdsV1() override;

  void GetForUserModel(
      const targeting::UserModelInfo& user_model,
      GetEligibleAdsCallback<CreativeNewTabPageAdList> callback) override;

 private:
  void GetEligibleAds(
      const targeting::UserModelInfo& user_model,
      const AdEventList& ad_events,
      const BrowsingHistoryList& browsing_history,
      GetEligibleAdsCallback<CreativeNewTabPageAdList> callback);

  void GetForChildSegments(
      const targeting::UserModelInfo& user_model,
      const AdEventList& ad_events,
      const BrowsingHistoryList& browsing_history,
      GetEligibleAdsCallback<CreativeNewTabPageAdList> callback);

  void GetForParentSegments(
      const targeting::UserModelInfo& user_model,
      const AdEventList& ad_events,
      const BrowsingHistoryList& browsing_history,
      GetEligibleAdsCallback<CreativeNewTabPageAdList> callback);

  void GetForUntargeted(
      const AdEventList& ad_events,
      const BrowsingHistoryList& browsing_history,
      GetEligibleAdsCallback<CreativeNewTabPageAdList> callback);

  CreativeNewTabPageAdList FilterCreativeAds(
      const CreativeNewTabPageAdList& creative_ads,
      const AdEventList& ad_events,
      const BrowsingHistoryList& browsing_history);
};

}  // namespace new_tab_page_ads
}  // namespace ads

#endif  // BRAVE_VENDOR_BAT_NATIVE_ADS_SRC_BAT_ADS_INTERNAL_ELIGIBLE_ADS_NEW_TAB_PAGE_ADS_ELIGIBLE_NEW_TAB_PAGE_ADS_V1_H_
