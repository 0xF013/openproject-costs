//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

// main app
var openprojectCostsApp = angular.module('openproject');

openprojectCostsApp.run(['HookService', function(HookService) {
  var setupCostsAttributes = function(attributes) {
    var spentTimeIndex = attributes.indexOf('spentTime');
    var costsAttributes = {
      overallCosts: null,
      spentHours: 'spentHoursLinked',
      costObject: null,
      summarizedCostEntries: 'spentUnits'
    };

    angular.forEach(costsAttributes, function(id, costAttribute) {
      attributes.push(id || costAttribute);
    });

    if (spentTimeIndex >= 0) {
      attributes.splice(spentTimeIndex, 1);
    }
  }

  HookService.register('workPackagePluginAttributes', function(params) {
    var costsActivted = params.enabledModules.indexOf('costs_module') >= 0;

    if (costsActivted) {
      setupCostsAttributes(params.attributes)
    }
  });

  HookService.register('workPackageOverviewAttributes', function(params) {
    var directive;

    switch (params.type) {
      case "spentUnits":
        if (params.workPackage.embedded.summarizedCostEntries.length > 0) {
          directive = "summarized-cost-entries";
        }
        break;
      case "costObject":
        if (params.workPackage.embedded.costObject) {
          directive = "cost-object";
        }
        break;
      case "spentHoursLinked":
        if (params.workPackage.props.spentHours) {
          directive = "spent-hours";
        }
        break;
    }

    return directive;
  });

  HookService.register('workPackageDetailsMoreMenu', function(params) {
    return { "log_costs": ["icon-unit"] };
  });
}]);
