import 'package:flokk/_internal/components/seperated_flexibles.dart';
import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/_internal/utils/color_utils.dart';
import 'package:flokk/_internal/widget_view.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/social_activity_type.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/buttons/transparent_btn.dart';
import 'package:flokk/styled_components/scrolling/styled_scrollview.dart';
import 'package:flokk/styled_components/styled_progress_spinner.dart';
import 'package:flokk/styled_components/styled_user_avatar.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flokk/views/contact_edit/contact_edit_panel.dart';
import 'package:flokk/views/contact_edit/miniforms/address_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/birthday_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/email_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/events_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/job_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/label_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/name_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/notes_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/phone_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/relationship_miniform.dart';
import 'package:flokk/views/contact_edit/miniforms/social_miniforms.dart';
import 'package:flokk/views/contact_edit/miniforms/website_miniform.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactEditFormView
    extends WidgetView<ContactEditForm, ContactEditFormState> {
  ContactEditFormView(ContactEditFormState state, {Key? key})
      : super(state, key: key);

  BuildContext get context => state.context;

  ContactData get contact => state.tmpContact;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    return state.isLoading
        ? Center(child: StyledProgressSpinner())
        : Column(
            children: <Widget>[
              SizedBox(height: Insets.sm),

              /// Top Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TransparentTextBtn(
                    "CANCEL",
                    bigMode: true,
                    color: theme.grey,
                    onPressed: state.handleCancelPressed,
                  ).translate(offset: Offset(-Insets.sm, 0)),
                  TransparentTextBtn(
                    "SAVE",
                    bigMode: true,
                    onPressed: state.handleSavePressed,
                  ).translate(offset: Offset(Insets.sm, 0)),
                ],
              ).padding(horizontal: Insets.l),

              StyledScrollView(
                child: Column(
                  children: [
                    VSpace(3),

                    /// Profile Pic
                    StyledUserAvatar(
                      contact: contact,
                      size: 110,
                    ),

                    VSpace(Insets.sm),

                    TransparentTextBtn(
                      "Upload a photo",
                      bigMode: true,
                      onPressed: state.handlePhotoPressed,
                    ),

                    VSpace(Insets.l),

                    /// Form fields
                    SeparatedColumn(
                      separatorBuilder: () => VSpace(Insets.m),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Name
                        ContactNameMiniForm(state),

                        /// Labels
                        ContactLabelMiniForm(state),

                        /// Email
                        ContactEmailMiniForm(state),

                        /// Phone
                        ContactPhoneMiniForm(state),

                        /// Twitter
                        ContactSocialMiniForm(
                            state, SocialActivityType.Twitter),

                        /// Git
                        ContactSocialMiniForm(state, SocialActivityType.Git),

                        /// Address
                        ContactAddressMiniForm(state),

                        /// Job
                        ContactJobMiniForm(state),

                        /// BIRTHDAY
                        ContactBirthdayMiniForm(state),

                        /// EVENTS
                        ContactEventsMiniForm(state),

                        /// Links
                        ContactWebsiteMiniForm(state),

                        /// NOTES
                        ContactNotesMiniForm(state),

                        /// Relationships, set a smaller maxDropdownHeight since we're near the bottom of the view
                        ContactRelationshipMiniForm(state,
                            maxDropdownHeight: 140),

                        if (!contact.isNew)
                          BaseStyledBtn(
                            hoverColor: theme.isDark
                                ? ColorUtils.shiftHsl(theme.bg1, .2)
                                : theme.bg2.withOpacity(.35),
                            child: Text("DELETE THIS CONTACT",
                                style: TextStyles.T1.textColor(theme.error)),
                            onPressed: state.handleDeletePressed,
                          ).padding(vertical: Insets.m),

                        //Add some extra padding at the bottom to account for the Relationship Dropdown menu
                        VSpace(30),
                      ],
                    ).padding(horizontal: Insets.l, bottom: Insets.m)
                  ],
                ),
              ).flexible(),
              SizedBox(height: Insets.m),
            ],
          );
  }
}
