# iSH User Setup Script

This repository provides a simple script to create a non-root user with `zsh` as the default shell and elevated privileges using `doas` in the iSH environment. This setup enhances security and usability by avoiding the use of the root account for everyday tasks.

## **What This Repository Does**

- **Installs Necessary Packages:** Ensures that `zsh` and `doas` are installed.
- **Creates a New User:** Sets up a new user without a password and assigns `zsh` as their default shell.
- **Configures `doas`:** Grants the new user the ability to execute commands with root privileges without requiring a password.

## **Quick Start**

To quickly set up your environment, run the following command in your iSH terminal:

```sh
wget https://raw.githubusercontent.com/stavytskyi/ish-setup/main/setup-user.sh -O setup_user.sh && sh setup_user.sh && rm setup_user.sh
```

## Post Installation Steps

1. **Switch to the new user**:
   - To switch to the created user, run:
     ```sh
     su - NEW_USER
     ```

2. **Set the new user as default login in iSH**:
   - To set the new user as the default when starting iSH:
     - Tap and hold the gear icon on the iSH keyboard for 10 seconds to access advanced settings.
     - Change the "Launch cmd" from:
       ```sh
       /bin/login -f root
       ```
       to:
       ```sh
       /bin/login -f NEW_USER
       ```
     - Save the changes and restart the iSH app.

3. **Using `doas` for root privileges**:
   - To perform tasks that require root privileges, you can use `doas`. For example, to install a package:
     ```sh
     doas apk add package_name
     ```
     
## License

This project is licensed under the [MIT License](LICENSE).
