import PullPolicies.NeverPullImagePolicy;
import org.junit.After;
import org.junit.Before;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testcontainers.containers.Container;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.output.Slf4jLogConsumer;
import org.testcontainers.containers.wait.strategy.Wait;

import java.io.IOException;

import static org.junit.Assert.fail;

public abstract class ContainerTestBase {
    private static final Logger logger = LoggerFactory.getLogger(ContainerTestBase.class);
    private static final Integer nodeCount = 3;

    private GenericContainer[] _containers;

    @Before
    public void setUp() {
        String dockerImageTag = System.getProperty("image_tag");

        logger.info("Tested Docker image tag: {}", dockerImageTag);

        Network network = Network.newNetwork();

        _containers = new GenericContainer[nodeCount];

        for(int i = 0; i < nodeCount; i++) {
            _containers[i] = new GenericContainer<>(dockerImageTag)
                    .withNetwork(network)
                    .withNetworkAliases("node" + (i + 1))
                    .withPrivilegedMode(true) // Required to allow extended attributes in the trusted space
                    .withImagePullPolicy(new NeverPullImagePolicy())
                    .waitingFor(Wait.forLogMessage("(.*)end-volume(.*)", 1));

            _containers[i].start();
            _containers[i].followOutput(new Slf4jLogConsumer(logger));
        }
    }

    @After
    public void cleanUp() {
        for(int i = 0; i < nodeCount; i++) {
            _containers[i].stop();
            _containers[i].close();
        }
    }

    protected GenericContainer getContainer(int index) {
        return _containers[index];
    }

    protected Container.ExecResult execInContainer(int containerIndex, String command) throws IOException, InterruptedException {
        Container.ExecResult result = getContainer(containerIndex).execInContainer(command.split(" "));

        verifyExitCode(command, result);

        return result;
    }

    protected Container.ExecResult execBashCommandInContainer(int containerIndex, String bashCommand) throws IOException, InterruptedException {
        Container.ExecResult result = getContainer(containerIndex).execInContainer("bash", "-c", bashCommand);

        verifyExitCode(bashCommand, result);

        return result;
    }

    protected void execInEachContainer(String command) throws IOException, InterruptedException {
        for(int i = 0; i < nodeCount; i++) {
            Container.ExecResult result = getContainer(i).execInContainer(command.split(" "));

            verifyExitCode(command, result);
        }
    }

    private void verifyExitCode(String command, Container.ExecResult execResult) {
        if(execResult.getExitCode() != 0) {
            StringBuilder builder = new StringBuilder();
            builder.append("The command '"+ command +"' returned failing exit code: " + execResult.getExitCode());

            builder.append(System.lineSeparator());
            builder.append(System.lineSeparator());

            builder.append("StdOut: ");
            builder.append(execResult.getStdout());

            builder.append(System.lineSeparator());
            builder.append(System.lineSeparator());

            builder.append("StdErr: ");
            builder.append(execResult.getStderr());

            fail(builder.toString());
        }
    }
}