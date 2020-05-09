#!/usr/bin/python3

"""
A script for submitting classifier jobs for all unclassified DICOMs in a project.
This script makes the assumption that files lacking a file.modality have not yet
had the dicom-mr-classifier run on them.

It is recommended that you first run the command with the -v and -dry-run flags
to preview the behavior of this script prior to execution without the dry-run parameter.
You do not need to provide an api key if you're logged in with the Flywheel CLI

Command structure:

    python3 <path to this script> <project id> [-v] [-dry-run] [-api-key <api key>]

Example dry run command:

    python3 /path/to/classify_unclassified_dicoms_ZD3443.py 5e90d7a5a3803400a8e63b13 -v --dry-run -api-key demo.flywheel.io:garbage

Example real (actually submit jobs) command:
    python3 /path/to/classify_unclassified_dicoms_ZD3443.py 5e90d7a5a3803400a8e63b13 -api-key demo.flywheel.io:garbage

"""
import argparse
import logging
import re

import flywheel

log = logging.getLogger('classify_unclassified_DICOMs')

# Default configuration for dicom-mr-classifier
DEFAULT_CONFIG = {'force': False, 'timezone': 'UTC'}


def run_classifier(fw_client, file_obj, config_dict, dry_run=True):
    """
    Submits a dicom-mr-classifier job for file_obj with config_dict as config
    Args:
        fw_client (flywheel.Client): an instance of the flywheel client
        file_obj (flywheel.FileEntry): the file for which to submit a classifier job
        config_dict (dict): dictionary specifying configuration options for dicom-mr-classifier
        dry_run (bool): If true, submit a job, otherwise, just log the debug statement

    Returns:
        str: the id of the submitted job
    """
    # Get the gear
    gear = fw_client.lookup('gears/dicom-mr-classifier')
    # Set the destination to the file's parent container
    dest = file_obj.parent
    # Set the input dictionary
    inputs = {'dicom': file_obj}
    log.debug('Submitting classifier job for %s %s file %s', dest.container_type, dest.id, file_obj.name)
    if not dry_run:
        try:
            gear_job_id = gear.run(config=config_dict, inputs=inputs, destination=dest)
            log.debug('Submitted job %s', gear_job_id)
            return gear_job_id
        except flywheel.rest.ApiException:
            log.error('An exception was raised when attempting to submit a job for %s',
                      file_obj.name,
                      exc_info=True
                      )


def get_unclassified_acquisition_files_from_project(project_obj):
    """
    Gets a list of files of type dicom with undefined modality (unclassified)

    Args:
        project_obj (flywheel.Project): the flywheel project container to search

    Returns:
        list: a list of flywheel.FileEntry objects of type dicom with undefined modality
            (unclassified) within project_obj
    """
    # Initialize list
    unclass_files = list()
    # We want acquisitions with files of type dicom and files with undefined modality
    query = 'files.type=dicom,files.modality=null'
    # Iterate over project sessions
    for session in project_obj.sessions.iter():
        # Find acquisitions matching query
        for acq in session.acquisitions.find(query):
            for file_obj in acq.files:
                # We only want DICOMs that have undefined modality
                if file_obj.type == 'dicom' and not file_obj.modality:
                    # append to the list
                    unclass_files.append(file_obj)
    return unclass_files


def get_api_url_key(client_config_site_api_url, current_user_key):
    """Removes /api and port (i.e., :443) from client_config_site_api_url.

    Args:
        client_config_site_api_url (str): the value for client.get_config().site.api_url
        current_user_key (str): value of client.get_current_user().api_key.key

    Returns:
        api_key (str): tan api key that can be used to instantiate a client with the
            Flywheel SDK

    """
    # Remove http(s)://
    no_http = client_config_site_api_url.split('//')[1]
    # Remove /api and port (i.e., :443) from no http
    remove_regex = r'(:[\d]+)?/api'
    api_url = re.sub(remove_regex, '', no_http)
    # Format the key as <api_url>:<current_user_key>
    api_key = ':'.join([api_url, current_user_key])
    return api_key


def get_root_client(fw_client):
    """
    Takes a flywheel client and gives it root mode if the user is site admin, otherwise just returns the input client

    Args:
        fw_client (flywheel.Client): an instance of the flywheel client

    Returns:
        fw_client: an instance of the flywheel client with root mode enabled if user is site admin

    """

    # parse the "url:" part of the api key from the site url
    site_url = fw_client.get_config().site.api_url

    user = fw_client.get_current_user()
    api_key = get_api_url_key(site_url, user.api_key.key)
    # If the user is not admin, warn and return the input client
    if 'site_admin' not in user.get('roles'):
        log.warning('User {} is not a site admin. Root mode will not be enabled.'.format(user.id))
        log.warning('User roles: {}'.format(user['roles']))
    else:
        fw_client = flywheel.Client(api_key, root=True)
    return fw_client


def classify_unclassified_dicoms(fw_client, project_id, dry_run=True, verbose=True):
    """

    Args:
        fw_client (flywheel.Client): an instance of the flywheel client
        project_id (str): a flywheel project id
        dry_run (bool): if True, do not submit jobs, just log
        verbose (bool): if True, print debug statements

    Returns:

    """
    project = None
    # Set log level
    if verbose:
        log.setLevel('DEBUG')
    else:
        log.setLevel('INFO')

    # Try to get the project for the provided ID
    try:
        project = fw_client.get_project(project_id)
        log.info('Finding unclassified files in project %s', project.label)
    # Anticipate user error
    except flywheel.rest.ApiException:
        log.error(
            'Could not retrieve project with id %s due to exception',
            project_id,
            exc_info=True
        )
        project = None

    if project is not None:
        # Get unclassified files
        unclass_files = get_unclassified_acquisition_files_from_project(project)
        log.info('Found %d files without modality.', len(unclass_files))
        if unclass_files:
            log.info('Submitting %d dicom-mr-classifier jobs', len(unclass_files))
        # Initialize job_list
        job_list = list()
        # Submit jobs for unclassified files
        for file_ in unclass_files:
            job_id = run_classifier(
                fw_client=fw_client,
                file_obj=file_,
                config_dict=DEFAULT_CONFIG,
                dry_run=dry_run
            )
            job_list.append(job_id)
        # Remove None jobs
        job_list = [job_id for job_id in job_list if job_id is not None]
        if job_list:
            log.info('Successfully submitted %d jobs', len(job_list))
            if verbose:
                log.debug('Submitted job IDs')
                for job_id in job_list:
                    log.debug('%s', job_id)
            return job_list


if __name__ == '__main__':

    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('project_id', help='Flywheel project id')
    parser.add_argument('--verbose', '-v', action='store_true')
    parser.add_argument('--api-key', help='Use if not logged in via cli')
    parser.add_argument('--dry-run', action='store_true',
                        help='Do not actually submit jobs, only log information')

    args = parser.parse_args()

    # Create client
    if args.api_key:
        fw = flywheel.Client(args.api_key)
        fw = get_root_client(fw_client=fw)
    else:
        fw = flywheel.Client()

    job_list = classify_unclassified_dicoms(fw_client=fw, project_id=args.project_id,
                                            verbose=args.verbose, dry_run=args.dry_run)
