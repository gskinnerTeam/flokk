import 'dart:math';

import 'package:flokk/commands/contacts/refresh_contacts_command.dart';
import 'package:flokk/commands/groups/add_label_to_contact_command.dart';
import 'package:flokk/commands/groups/create_label_command.dart';
import 'package:flokk/commands/groups/delete_label_command.dart';
import 'package:flokk/commands/groups/refresh_contact_groups_command.dart';
import 'package:flokk/commands/groups/remove_label_from_contact_command.dart';
import 'package:flokk/commands/groups/rename_label_command.dart';
import 'package:flokk/commands/groups/update_contact_labels_command.dart';
import 'package:flokk/data/contact_data.dart';
import 'package:flokk/data/group_data.dart';
import 'package:flokk/models/contacts_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommandTestingSpike extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final contactModel = Provider.of<ContactsModel>(context, listen: false);
    ContactData contact = contactModel.allContacts.first;
    GroupData group = GroupData();

    return Container(
      child: Column(
        children: <Widget>[
          Text("Test contact to apply labels to: ${contact.nameFull}"),
          ElevatedButton(
            child: Text("refresh groups"),
            onPressed: () async {
              List<GroupData> groups = await RefreshContactGroupsCommand(context).execute();
              print(groups.map((x) => x.name).toList().join(","));
            },
          ),
          ElevatedButton(
            child: Text("refresh contacts"),
            onPressed: () async {
              await RefreshContactsCommand(context).execute();
            },
          ),
          ElevatedButton(
            child: Text("create label"),
            onPressed: () async {
              group = await CreateLabelCommand(context).execute("MyNewLabel") ?? group;
              print(group);
            },
          ),
          ElevatedButton(
            child: Text("edit label"),
            onPressed: () async {
              group.name = "Renamed Label";
              group = (await RenameLabelCommand(context).execute(group)) ?? group;
              print(group);
            },
          ),
          ElevatedButton(
            child: Text("add multiple labels to single contact"),
            onPressed: () async {
              List<GroupData> userLabels =
                  contactModel.allGroups.where((x) => x.groupType == GroupType.UserContactGroup).toList();
              int length = min(userLabels.length, 3);
              List<GroupData> firstThreeLabels = userLabels.sublist(0, length);
              contact.groupList = firstThreeLabels;
              firstThreeLabels.forEach((element) {
                print("LABEL: ${element.name}");
              });
              UpdateContactLabelsCommand(context).execute(contact);
            },
          ),
          ElevatedButton(
            child: Text("add single label to multiple contacts"),
            onPressed: () async {
              if (contactModel.allGroups.isNotEmpty) {
                GroupData firstLabel =
                    contactModel.allGroups.where((x) => x.groupType == GroupType.UserContactGroup).first;
                List<ContactData> faves = contactModel.allContacts.where((x) => x.isStarred == true).toList();
                int length = min(faves.length, 3);
                List<ContactData> firstThreeContacts = faves.sublist(0, length);
                AddLabelToContactCommand(context).execute(firstThreeContacts, existingGroup: firstLabel);
                print("Add ${firstLabel.name} to ${firstThreeContacts.map((x) => x.nameFull).toList().join(', ')}");
              }
            },
          ),
          ElevatedButton(
            child: Text("add new label to contact"),
            onPressed: () async {
              List<ContactData> updatedContact = await AddLabelToContactCommand(context)
                  .execute([contact], newLabel: "Foo");
              print(updatedContact.first);
            },
          ),
          ElevatedButton(
            child: Text("add existing label to contact"),
            onPressed: () async {
              List<ContactData> updatedContact =
                  await AddLabelToContactCommand(context).execute([contact], existingGroup: group);
              print(updatedContact.first);
            },
          ),
          ElevatedButton(
            child: Text("remove label from contact"),
            onPressed: () async {
              ContactData? updatedContact = await RemoveLabelFromContactCommand(context).execute(contact, group);
              print(updatedContact);
            },
          ),
          ElevatedButton(
            child: Text("delete label"),
            onPressed: () async {
              bool success = await DeleteLabelCommand(context).execute(group);
              print(success);
            },
          ),
        ],
      ),
    );
  }
}
