import org.junit.Test;

import java.io.IOException;

import static org.junit.Assert.assertEquals;

public class GlusterShould extends ContainerTestBase {
    @Test
    public void buildClusterWithReplicatedVolume() throws IOException, InterruptedException {
        // Connect the nodes into a cluster
        execInContainer(0, "gluster peer probe node2");
        execInContainer(0, "gluster peer probe node3");

        // Create local directories for the volumes
        execInEachContainer("mkdir -p /gluster/brick");

        // Create volume
        execInContainer(0, "gluster volume create gfs replica 3 " +
                "node1:/gluster/brick " +
                "node2:/gluster/brick " +
                "node3:/gluster/brick force"); // force is required because the volume is created in the root partition which is not recommended

        execInContainer(0, "gluster volume start gfs");

        // Mount the volume to simplify interaction
        execInEachContainer("mount.glusterfs localhost:/gfs /mnt");

        // Write a file
        execBashCommandInContainer(2,"echo Hello > /mnt/test-file");

        // Verify the same file is available in the other two containers
        assertEquals("Hello", execInContainer(1, "cat /mnt/test-file").getStdout().trim());
        assertEquals("Hello", execInContainer(0, "cat /mnt/test-file").getStdout().trim());
    }
}