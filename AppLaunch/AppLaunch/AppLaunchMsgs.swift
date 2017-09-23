//
//  AppLaunchPrompts.swift
//  AppLaunch
//
//  Created by Chethan Kumar on 9/23/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation


//
// ─── POSITIVE MESSAGES ───────────────────────────────────────────────────────────
//


internal let MSG__USER_ALREADY_REGISTERED = "User is already Registered. If you intend to update the user, use the updateUser API"


//
// ─── ERROR MESSAGES ───────────────────────────────────────────────────────────
//

internal let MSG__CLIENT_OR_APPID_NOT_VALID = "Error while initializing - Client secret or applicationID is not valid"

internal let MSG__ERR_GET_ACTIONS = "Error while getting actions"

internal let MSG__ERR_NOT_REG_NOT_INIT = "Error while getting actions. AppLaunch is not initialized or the user is not registered. Register the user before requesting for actions"

internal let MSG__ERR_METRICS_NOT_INIT = "Error while sending metrics. AppLaunch is not initialized or the user is not registered. Register the user before sending metrics"
