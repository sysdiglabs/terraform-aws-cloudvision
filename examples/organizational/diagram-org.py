# diagrams as code vía https://diagrams.mingrammer.com
from diagrams import Diagram, Cluster, Diagram, Edge, Node
from diagrams.aws.general import General
from diagrams.aws.management import Cloudtrail
from diagrams.aws.storage import S3, SimpleStorageServiceS3Bucket
from diagrams.aws.integration import SNS
from diagrams.aws.integration import SQS
from diagrams.aws.compute import ECS, ElasticContainerServiceService
from diagrams.aws.security import IAMRole,IAM
from diagrams.aws.management import Cloudwatch


diagram_attr = {
    "pad":"0.25"
}

role_attr = {
   "height":"1",
   "width":"0.8",
   "fontsize":"9",
}

event_color="firebrick"

with Diagram("Sysdig Cloudvision{}(organizational usecase)".format("\n"), graph_attr=diagram_attr, filename="diagram-org", show=True):

    with Cluster("AWS organization"):

        with Cluster("other accounts (member)", graph_attr={"bgcolor":"lightblue"}):
            member_accounts = [General("account-1"),General("..."),General("account-n")]

            org_member_role = IAMRole("OrganizationAccountAccessRole\ncreated by AWS for org. member accounts", **role_attr)


        with Cluster("master account"):


            cloudtrail          = Cloudtrail("cloudtrail", shape="plaintext")
            cloudtrail_legend = ("for clarity purpose events received from cloudvision member account\n\
                                    and master account have been removed from diagram, but will be processed too ")
            Node(label=cloudtrail_legend, width="5",shape="plaintext", labelloc="t", fontsize="10")


            master_credentials = IAM("master-credentials \npermissions: cloudtrail, role creation", fontsize="10")
            cloudvision_role    = IAMRole("Sysdig-Cloudvision-Role", **role_attr)
            cloudtrail_s3       = S3("cloudtrail-s3-events")
            sns                 = SNS("cloudtrail-sns-events", comment="i'm a graph")

            cloudtrail >> Edge(color=event_color, style="dashed") >> cloudtrail_s3 >> Edge(color=event_color, style="dashed") >> sns

        with Cluster("cloudvision account (member)", graph_attr={"bgcolor":"seashell2"}):

            org_member_role = IAMRole("OrganizationAccountAccessRole\ncreated by AWS for org. member accounts", **role_attr)

            with Cluster("ecs"):
                ecs = ECS("cloudvision")
                cloud_connector = ElasticContainerServiceService("cloud-connector")
                ecs - cloud_connector

            sqs = SQS("cloudtrail-sqs")
            s3_config = S3("cloud-connector-config")
            cloudwatch = Cloudwatch("cloudwatch\nlogs and alarms")

            sqs << Edge(color=event_color) << cloud_connector
            cloud_connector - s3_config
            cloud_connector - cloudwatch


        member_accounts >> Edge(color=event_color, style="dashed") >>  cloudtrail
        sns >> Edge(color=event_color, style="dashed") >> sqs
#        cloudtrail_s3 << Edge(color=event_color) << cloud_connector
        (cloudtrail_s3 << Edge(color=event_color) << cloudvision_role) -  Edge(xlabel="assumeRole", color=event_color) - cloud_connector
