package PullPolicies;

import org.testcontainers.images.ImagePullPolicy;
import org.testcontainers.utility.DockerImageName;

public class NeverPullImagePolicy implements ImagePullPolicy {
    @Override
    public boolean shouldPull(DockerImageName imageName) {
        return false;
    }
}