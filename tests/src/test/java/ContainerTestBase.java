import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.containers.wait.strategy.Wait;

import java.io.IOException;

public abstract class ContainerTestBase {
    private static final Logger logger = LoggerFactory.getLogger(ContainerTestBase.class);
    private static final Integer nodeCount = 3;

    private static GenericContainer[] _containers;

    @BeforeClass
    public static void setUp() throws IOException, InterruptedException {
        String dockerImageTag = System.getProperty("image_tag", "homecentr/gluster");

        logger.info("Tested Docker image tag: {}", dockerImageTag);

        Network network = Network.newNetwork();

        for(int i = 0; i < nodeCount; i++) {
            _containers[i] = new GenericContainer<>(System.getProperty("image_tag", dockerImageTag))
                    .withNetwork(network)
                    .withNetworkAliases("node" + i)
                    .waitingFor(Wait.forLogMessage(".*end-volume.*", 1));

            _containers[i].start();
            _containers[i].followOutput(new Slf4jLogConsumer(logger));
        }

        for(int i = 0; i < nodeCount; i++) {
            _containers[0].execInContainer("gluster peer probe node" + i);
        }
    }

    @AfterClass
    public static void cleanUp() {
        for(int i = 0; i < nodeCount; i++) {
            _containers[i].stop();
            _containers[i].close();
        }
    }

    protected GenericContainer getContainer(int index) {
        return _containers[index];
    }
}