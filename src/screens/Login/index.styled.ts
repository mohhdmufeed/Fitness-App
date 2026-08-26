import {StyleSheet} from 'react-native'

import BorderRadius from '@styles/borderRadius'
import FontSize from '@styles/fontSize'
import Shadow from '@styles/shadow'
import Spacing from '@styles/spacing'
import {Theme} from '@styles/theme'

const APP_ICON_SIZE = 88

export default StyleSheet.create({
  gradient: {
    flex: 1
  },
  container: {
    flex: 1,
    paddingHorizontal: Spacing.LARGE + Spacing.XX_SMALL,
    paddingBottom: Spacing.X_LARGE
  },
  safeArea: {
    flex: 1
  },
  // flexGrow (not flex) so short screens can scroll past the viewport while
  // tall screens still pin the footer to the bottom via its marginTop: 'auto'
  scrollContent: {
    flexGrow: 1
  },
  brandContainer: {
    alignItems: 'center',
    rowGap: Spacing.MEDIUM,
    marginTop: Spacing.X_LARGE * 2
  },
  appIcon: {
    ...Shadow.ICON_GLOW,
    width: APP_ICON_SIZE,
    height: APP_ICON_SIZE,
    borderRadius: BorderRadius.CARD_LG + 2
  },
  appName: {
    fontSize: FontSize.STAT_LG,
    fontWeight: '700',
    letterSpacing: -0.3
  },
  tagline: {
    fontSize: FontSize.BODY,
    color: Theme.colors.textSecondary,
    marginTop: -Spacing.X_SMALL
  },
  formContainer: {
    rowGap: Spacing.SMALL,
    marginTop: Spacing.X_LARGE + Spacing.MEDIUM
  },
  input: {
    backgroundColor: Theme.colors.card,
    borderWidth: 1,
    borderColor: Theme.colors.inputBorder,
    borderRadius: BorderRadius.INPUT,
    paddingVertical: Spacing.MEDIUM,
    paddingHorizontal: Spacing.MEDIUM,
    fontSize: FontSize.H3
  },
  inputError: {
    borderColor: Theme.colors.danger
  },
  errorText: {
    fontSize: FontSize.CAPTION,
    color: Theme.colors.danger,
    marginTop: -Spacing.XX_SMALL,
    marginLeft: Spacing.XX_SMALL
  },
  forgotPasswordButton: {
    alignSelf: 'flex-end'
  },
  dividerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    columnGap: Spacing.SMALL,
    marginVertical: Spacing.XX_SMALL
  },
  dividerLine: {
    flex: 1,
    height: StyleSheet.hairlineWidth,
    backgroundColor: Theme.colors.inputBorder
  },
  dividerText: {
    fontSize: FontSize.CAPTION,
    color: Theme.colors.textSecondary
  },
  forgotPasswordLink: {
    fontSize: FontSize.CAPTION,
    fontWeight: '600',
    color: Theme.colors.accentGreen
  },
  footer: {
    marginTop: 'auto',
    flexDirection: 'row',
    justifyContent: 'center',
    paddingTop: Spacing.MEDIUM
  },
  footerText: {
    fontSize: FontSize.PARAGRAPH,
    color: Theme.colors.textSecondary
  },
  footerLink: {
    fontSize: FontSize.PARAGRAPH,
    fontWeight: '600',
    color: Theme.colors.accentGreen
  },
  offlineButton: {
    backgroundColor: Theme.colors.card,
    borderWidth: 1,
    borderColor: Theme.colors.accentGreen,
    borderRadius: BorderRadius.INPUT,
    paddingVertical: Spacing.MEDIUM,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: Spacing.X_SMALL
  },
  offlineButtonText: {
    fontSize: FontSize.H3,
    fontWeight: '600',
    color: Theme.colors.accentGreen
  }
})
