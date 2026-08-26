import * as Location from 'expo-location'
import * as TaskManager from 'expo-task-manager'

import {runPointBuffer} from '../run/runPointBuffer'

/**
 * Name of the OS-level background location task. Started/stopped via
 * `Location.startLocationUpdatesAsync` / `Location.stopLocationUpdatesAsync`
 * in `RunSessionService`.
 */
export const RUN_LOCATION_TASK = 'run-location-task'

// Defined at module top level (not inside a React component/hook) so it is
// registered on every JS bundle evaluation, including headless/background
// relaunches the OS performs to deliver location batches after the app was
// killed. This file must be imported unconditionally from index.js, before
// registerRootComponent, so the import happens even if App.tsx never mounts.
//
// The task callback must be fast, side-effect-light, and idempotent: it only
// appends raw points to the durable on-disk buffer for the currently active
// run (resolved by runPointBuffer from the persisted session record — see
// runPointBuffer.ts for how the active run id is threaded through). No
// filtering/math runs here; that happens later in RunSessionService.stop()
// via runMath.
try {
  TaskManager.defineTask(RUN_LOCATION_TASK, async ({data, error}) => {
    if (error || !data) {
      return
    }

    const {locations} = data as {locations: Location.LocationObject[]}

    if (!locations || locations.length === 0) {
      return
    }

    await runPointBuffer.appendToActiveRun(locations)
  })
} catch (err) {
  console.warn('[LocationTask] Failed to register task safely:', err)
}

