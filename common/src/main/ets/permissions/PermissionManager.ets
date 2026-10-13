import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

/** Permission denial is reported to the caller; it never terminates the app. */
export class PermissionManager {
  async requestPermissions(context: common.UIAbilityContext, permissions: Permissions[]): Promise<boolean> {
    const result = await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(context, permissions);
    return result.authResults.length === permissions.length &&
      result.authResults.every(status => status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED);
  }
}
