# Releasing

GwtBootstrap5 is published to Maven Central under the `io.github.gwtbootstrap5` namespace through the [Central Portal](https://central.sonatype.com). A release uploads the three artifacts of this reactor together: `gwtbootstrap5-parent` (pom), `gwtbootstrap5` and `gwtbootstrap5-extras`. Each one has a jar, a sources jar, a javadoc jar and GPG signatures.

## One-time setup

1. **Central Portal account.** Sign in at <https://central.sonatype.com> with an account that is an owner of the [gwtbootstrap5](https://github.com/gwtbootstrap5) GitHub organization.
2. **Namespace.** Under *Namespaces*, add `io.github.gwtbootstrap5`. The portal shows a verification key: create an empty public repository with that name in the `gwtbootstrap5` organization, click *Verify*, and delete the repository once the namespace shows as verified.
3. **User token.** Under *Account → Generate User Token*, create a token and add it to `~/.m2/settings.xml`:

   ```xml
   <settings>
     <servers>
       <server>
         <id>central</id>
         <username>TOKEN_USERNAME</username>
         <password>TOKEN_PASSWORD</password>
       </server>
     </servers>
   </settings>
   ```

4. **GPG key.** Central rejects unsigned artifacts and checks the signatures against public key servers:

   ```sh
   gpg --full-generate-key                      # RSA 4096, your name and e-mail
   gpg --list-secret-keys --keyid-format=long   # note the key id
   gpg --keyserver keyserver.ubuntu.com --send-keys KEY_ID
   gpg --keyserver keys.openpgp.org --send-keys KEY_ID
   ```

5. **NVD API key** (optional but recommended). The build runs the OWASP dependency check, which needs a free key from <https://nvd.nist.gov/developers/request-an-api-key> in the `NVD_API_KEY` environment variable. Without one, add `-Ddependency-check.skip=true` to the commands below.

## Releasing a version

The steps use `0.2.0` as the example.

1. **Versions and docs.** The version in the three poms is the release version, without `-SNAPSHOT`. `UPGRADING.md` and the "Final Release" section of the READMEs describe this release. The `gwtbootstrap5` and `gwtbootstrap5-extras` submodules point to their pushed `master`.
2. **Tests.** `mvn install`, plus the GWT tests: `mvn -pl gwtbootstrap5 -P test verify`.
3. **Dry run.** Build and sign everything without uploading:

   ```sh
   mvn -Prelease -DskipPublishing=true deploy
   unzip -l target/central-publishing/central-bundle.zip
   ```

   The bundle must have, for each artifact, the pom and jars with their `.asc`, `.md5` and `.sha1` files.
4. **Upload.** `mvn -Prelease deploy` uploads the bundle and waits until the portal validates it. The deployment then waits under *Deployments* in the portal. Check it there and click *Publish*; Maven Central shows it within about 30 minutes. A published version can't be deleted or replaced.
5. **Tags.** Tag the commit of each repository and push the tags:

   ```sh
   for repo in gwtbootstrap5 gwtbootstrap5-extras .; do
     git -C $repo tag -a v0.2.0 -m "GwtBootstrap5 0.2.0"
   done
   git -C gwtbootstrap5 push git@github.com:gwtbootstrap5/gwtbootstrap5.git v0.2.0
   git -C gwtbootstrap5-extras push git@github.com:gwtbootstrap5/gwtbootstrap5-extras.git v0.2.0
   git push git@github.com:gwtbootstrap5/gwtbootstrap5-parent.git v0.2.0
   ```

6. **GitHub releases.** In each repository, create a release from the `v0.2.0` tag. The parent's release carries the notes, which summarize `UPGRADING.md` and link to it. The others link to the parent's.
7. **Next version.** Bump the three poms to the next development version (for example `0.2.1-SNAPSHOT`) and commit.
