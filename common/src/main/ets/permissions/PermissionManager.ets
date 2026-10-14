import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

/** Permission denial is reported to the caller; it never terminates the app. */
export class PermissionManager {
  async requestPermissions(context: common.UIAbilityContext, permissions: Permissions[]): Promise<boolean> {
    const result = await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(context, permissions);
    if (result.authResults.length !== permissions.length) { return false; }
    const approximateIndex = permissions.indexOf('ohos.permission.APPROXIMATELY_LOCATION');
    const approximateGranted = approximateIndex >= 0 &&
      result.authResults[approximateIndex] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED;
    return permissions.every((permission: Permissions, index: number) =>
      result.authResults[index] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED ||
      (permission === 'ohos.permission.LOCATION' && approximateGranted));
  }
}
