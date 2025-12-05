import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../core/constant.dart';
import '../../core/sl.dart';
import '../../core/util/log.dart';
import '../blocs/setting/setting_bloc.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 3,
        title: const Text("Settings",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<SettingBloc, SettingState>(
        bloc: sl.get<SettingBloc>(),
        builder: (context, state) {
          final formKey = GlobalKey<FormBuilderState>();
          return FormBuilder(
            key: formKey,
            initialValue: {
              "web_url": state.config['web_url'] ??
                  getWebUrl(),
              "web_path": (state.config['web_path'] ?? getWebPath())
                  .toString()
                  .replaceFirst(getRootWebPath(), ""),
              "offline": state.config['offline']
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 24,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 16,
                            children: [
                              const Text("WEB URL"),
                              SizedBox(
                                height: 40,
                                child: FormBuilderTextField(
                                  name: "web_url",
                                  decoration: InputDecoration(
                                    hintText:
                                    getWebUrl(),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 8,
                                    ),
                                    border: const UnderlineInputBorder(),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        context.read<SettingBloc>().add(
                                              UpdateSettingEvent(
                                                config: {
                                                  "web_url":
                                                  getWebUrl(),
                                                },
                                              ),
                                            );
                                      },
                                      icon: const Icon(Icons.refresh),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                        onPressed: () {
                          final formState = formKey.currentState;
                          if (formState != null) {
                            if (formState.saveAndValidate()) {
                              logger.i(formState.value.toString());
                              context.read<SettingBloc>().add(
                                    UpdateSettingEvent(
                                      config: {
                                        ...formState.value,
                                        "web_path":
                                            "${getRootWebPath()}${formState.value['web_path']}",
                                      },
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  elevation: 2,
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.fixed,
                                  backgroundColor: Colors.white,
                                  content: Text(
                                    "Updated",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
