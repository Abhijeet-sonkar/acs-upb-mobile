import 'package:acs_upb_mobile/authentication/model/user.dart';
import 'package:acs_upb_mobile/authentication/service/auth_provider.dart';
import 'package:acs_upb_mobile/generated/l10n.dart';
import 'package:acs_upb_mobile/pages/filter/model/filter.dart';
import 'package:acs_upb_mobile/pages/filter/service/filter_provider.dart';
import 'package:acs_upb_mobile/resources/locale_provider.dart';
import 'package:acs_upb_mobile/resources/utils.dart';
import 'package:acs_upb_mobile/widgets/button.dart';
import 'package:acs_upb_mobile/widgets/dialog.dart';
import 'package:acs_upb_mobile/widgets/form/form.dart';
import 'package:acs_upb_mobile/widgets/scaffold.dart';
import 'package:acs_upb_mobile/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preference_title.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  List<FormItem> formItems;
  Filter filter;
  List<FilterNode> nodes;
  FilterProvider filterProvider;

  User _user;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  final editProfileForm = GlobalKey<FormState>();

  void _fetchInitialData() async {
    filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filter = await filterProvider.fetchFilter();
    AuthenticationProvider authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    _user = await authProvider.currentUser;

    List<String> path = List();
    if (_user.degree != null) {
      path.add(_user.degree);
      if (_user.domain != null) {
        path.add(_user.domain);
        if (_user.year != null) {
          path.add(_user.year);
          if (_user.series != null) {
            path.add(_user.series);
            if (_user.group != null) {
              path.add(_user.group);
            }
          }
        }
      }
    }
    nodes = filter.findNodeByPath(path);
    firstNameController.text = _user.firstName;
    lastNameController.text = _user.lastName;
    setState(() {});
  }

  initState() {
    super.initState();
    _fetchInitialData();
  }

  List<Widget> _dropdownTree(BuildContext context) {
    List<Widget> items = [SizedBox(height: 8)];

    if (filter == null || nodes == null) {
      items.add(Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(child: CircularProgressIndicator()),
      ));
    } else {
      for (var i = 0; i < nodes.length; i++) {
        if (nodes[i] != null && nodes[i].children.isNotEmpty) {
          items.add(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                child: Text(
                  filter.localizedLevelNames[i][LocaleProvider.localeString],
                  style: Theme.of(context)
                      .textTheme
                      .caption
                      .apply(color: Theme.of(context).hintColor),
                ),
              ),
              DropdownButtonFormField<FilterNode>(
                value: nodes.length > i + 1 ? nodes[i + 1] : null,
                items: nodes[i]
                    .children
                    .map((node) => DropdownMenuItem(
                          value: node,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(node.name),
                          ),
                        ))
                    .toList(),
                onChanged: (selected) => setState(
                  () {
                    nodes.removeRange(i + 1, nodes.length);
                    nodes.add(selected);
                  },
                ),
              ),
            ],
          ));
        }
      }
    }
    return items;
  }

  AppDialog _deletionConfirmationDialog(BuildContext context) => AppDialog(
        icon: Icon(Icons.warning, color: Colors.red),
        title: S.of(context).actionDeleteAccount,
        message: S.of(context).messageDeleteAccount +
            ' ' +
            S.of(context).messageCannotBeUndone,
        actions: [
          AppButton(
            key: ValueKey('delete_account_button'),
            text: S.of(context).actionDeleteAccount.toUpperCase(),
            color: Colors.red,
            width: 130,
            onTap: () async {
              AuthenticationProvider authProvider =
                  Provider.of<AuthenticationProvider>(context, listen: false);
              bool res = await authProvider.delete(context: context);
              if (res) {
                Utils.signOut(context);
              }
            },
          )
        ],
      );

  @override
  Widget build(BuildContext context) {
    AuthenticationProvider authProvider = Provider.of<AuthenticationProvider>(context);
    return AppScaffold(
      title: S.of(context).sectionEditProfile,
      actions: [
        AppScaffoldAction(
            text: S.of(context).buttonSave,
            onPressed: () async {
              if (editProfileForm.currentState.validate()) {
                bool result = await authProvider.updateProfile(
                  info: {
                    S.of(context).labelFirstName: firstNameController.text,
                    S.of(context).labelLastName: lastNameController.text,
                    filter.localizedLevelNames[0][LocaleProvider.localeString]:
                        nodes.length > 1 ? nodes[1].name : null,
                    filter.localizedLevelNames[1][LocaleProvider.localeString]:
                        nodes.length > 2 ? nodes[2].name : null,
                    filter.localizedLevelNames[2][LocaleProvider.localeString]:
                        nodes.length > 3 ? nodes[3].name : null,
                    filter.localizedLevelNames[3][LocaleProvider.localeString]:
                        nodes.length > 4 ? nodes[4].name : null,
                    filter.localizedLevelNames[4][LocaleProvider.localeString]:
                        nodes.length > 5 ? nodes[5].name : null,
                    filter.localizedLevelNames[5][LocaleProvider.localeString]:
                        nodes.length > 6 ? nodes[6].name : null,
                  },
                  context: context,
                );

                if (result) {
                  AppToast.show(S.of(context).messageEditProfileSuccess);
                  Navigator.pop(context);
                } else {
                  AppToast.show(S.of(context).errorSomethingWentWrong);
                }
              }
            }),
        AppScaffoldAction(
          icon: Icons.more_vert,
          items: {
            S.of(context).actionDeleteAccount: () => showDialog(
                context: context, child: _deletionConfirmationDialog(context))
          },
          onPressed: () => showDialog(
              context: context, child: _deletionConfirmationDialog(context)),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: FutureBuilder(
          future: authProvider.currentUser,
          builder: (BuildContext context, AsyncSnapshot<User> snap) {
            return Container(
              child: ListView(
                children: [
                      PreferenceTitle(
                        S.of(context).labelPersonalInformation,
                        leftPadding: 0,
                      ),
                      Form(
                        key: editProfileForm,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: S.of(context).labelFirstName,
                                hintText: S.of(context).hintFirstName,
                              ),
                              controller: firstNameController,
                              validator: (value) {
                                if (value.isEmpty || value == null) {
                                  return S.of(context).errorMissingFirstName;
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                labelText: S.of(context).labelLastName,
                                hintText: S.of(context).hintLastName,
                              ),
                              controller: lastNameController,
                              validator: (value) {
                                if (value.isEmpty || value == null) {
                                  return S.of(context).errorMissingLastName;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      PreferenceTitle(
                        S.of(context).labelClass,
                        leftPadding: 0,
                      ),
                    ] +
                    _dropdownTree(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
